FROM ubuntu:16.10

ENV TERM screen-256color

RUN apt-get update -qq && apt-get install -y wget
ADD apt-packages.txt /code/apt-packages.txt
RUN apt-get update -qq && cat /code/apt-packages.txt | xargs apt-get -qq --yes --force-yes install

RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN pip3 install virtualenv pip --upgrade
RUN virtualenv -p python3.6 /var/env/

ADD requirements.txt /code/requirements.txt
COPY ./dependencies /code/dependencies
RUN /var/env/bin/pip install -f /code/dependencies -r /code/requirements.txt

WORKDIR /code/

ADD ./ /code

ENTRYPOINT ["bash", "/code/entrypoint.sh"]
CMD ["manage", "runserver", "0.0.0.0:8000"]
