FROM --platform=amd64 ubuntu:20.04

RUN apt-get update && apt-get install -y \
  curl unzip ssh

WORKDIR /ghjk
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm -rf /ghjk

WORKDIR /ghjk
RUN curl -OLsf https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.1.0/ec2-instance-selector-linux-amd64.tar.gz
RUN tar -xvof ec2-instance-selector-linux-amd64.tar.gz
RUN chmod +x ./ec2-instance-selector
RUN mv ec2-instance-selector /usr/local/bin

WORKDIR /app

COPY . .

ENV PROMPT_COMMAND='history -a'
ENTRYPOINT ["/app/entrypoint.sh"]
