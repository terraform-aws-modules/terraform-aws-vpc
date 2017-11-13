FROM python:2.7-slim

LABEL Maintainers="Platform Team et al."
LABEL Type="helper, cicd, unittest"

WORKDIR /terraform_validate

RUN pip install --no-cache-dir --upgrade pip terraform_validate

CMD [ "python", "tests.py" ]