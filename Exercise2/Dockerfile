FROM python:3.13.0a4-slim-bullseye

WORKDIR /Exercise2

COPY . /Exercise2

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8080

CMD ["gunicorn", "-b", "0.0.0.0:8080", "calculator:app"]
