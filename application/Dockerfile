#FROM ubuntu:14.04
FROM python:3.9-slim
MAINTAINER Docker Education Team <education@docker.com>
RUN pip install --upgrade pip
#RUN apt-get update
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-all python-pip 
ADD ./webapp/requirements.txt /tmp/requirements.txt
RUN pip install -qr /tmp/requirements.txt
ADD ./webapp /opt/webapp/
WORKDIR /opt/webapp
EXPOSE 5000
CMD ["python", "app.py"]

