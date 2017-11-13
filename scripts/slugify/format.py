import unicodedata
import re
import os
import sys
import logging
import json

from django.utils.safestring import SafeText, mark_safe

def slugify(value, allow_unicode=False):
    """
    Convert to ASCII if 'allow_unicode' is False. Convert spaces to hyphens.
    Remove characters that aren't alphanumerics or hyphens.
    Convert to lowercase. Also strip leading and trailing whitespace and leading numbers.

    This is required to convert branch name to something that satisfies Google with
    regex `(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)`
    """

    value = str(value)
    if allow_unicode:
        value = unicodedata.normalize('NFKC', value)
    else:
        value = unicodedata.normalize('NFKD', value).encode('ascii', 'ignore').decode('ascii')
    value = re.sub(r'[^A-z0-9-_\s]+|[_]|[\^]', '-', value)
    value = re.sub(r'^(\d+)', '', value)
    value = re.sub(r'-+', '-', value).lower()[0:35]
    value = re.sub(r'-+$', '', value)
    return json.dumps({'ci_branch': mark_safe(value)}, indent=4, separators=(',', ': '))

logger = logging.getLogger()

try:
    os.environ['CI_BRANCH']
except KeyError:
    logger.error("""CI_BRANCH env variable is absent... exiting.

    CI_BRANCH is required to generate unique artifact ids.
    For example, Google image family names.
    If you see this error while running build locally,
    set env variables with ci/cd tool.

    For example:

    jet steps -e CI_COMMIT_ID=$(git rev-parse  HEAD) \\
    -e CI_BUILD_ID=local-build \\
    -e CI_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    Resulting json is written in /artifacts/packer-vars.json
    and to stdout.
    """, exc_info=True)
    sys.exit(1)

try:
    fjson = open("/artifacts/packer-vars.json", "w")
except KeyError:
    logger.error("""Please check CI/CD configuration, this container need /artifacts volume mounted.
    You probably want something like this:

    python-helper:
    volumes:
        - ./tmp:/artifacts
  """)

try:
    ftext = open("/artifacts/packer-vars.txt", "w")
except KeyError:
    logger.error("""Please check CI/CD configuration, this container need /artifacts volume mounted.
    You probably want something like this:

    python-helper:
    volumes:
        - ./tmp:/artifacts
  """)

result = slugify(os.environ['CI_BRANCH'])
fjson.write(result)
ftext.write(json.loads(result).get('ci_branch'))

print(result)