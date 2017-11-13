FROM python:3.3-slim

WORKDIR /usr/src/app

COPY ./scripts/slugify/ ./

RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python", "./format.py" ]

