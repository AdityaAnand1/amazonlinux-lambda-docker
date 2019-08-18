FROM amazonlinux

## Enable corretto8 (AWS Java 8) and install corretto8, nano, epel
RUN amazon-linux-extras enable corretto8
RUN amazon-linux-extras install -y nano epel corretto8

## Install OS packages
RUN yum -y -q upgrade \
    && yum -y -q update \
    && yum -y -q groupinstall "Development tools" \
    && yum -y -q install libxml2-devel libxslt-devel jq p which git tar \
    && yum -y -q install wget gcc zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel \
    && yum -y -q install python3 python3-devel

ENV JAVA_HOME="/usr/bin/java"

## Install Apache Maven yum repository
RUN wget -q http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
RUN sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
RUN yum -y -q install apache-maven

## Install pip for Python 2.7 for compatibility with Python applications requiring it
RUN wget https://bootstrap.pypa.io/get-pip.py && python2 get-pip.py

## Upgrade pip for both Python 2.7 and Python 3.7
RUN pip2 install -qqq --upgrade pip
RUN pip3 install -qqq --upgrade pip

RUN ln -s /usr/local/bin/pip3 /usr/bin/pip
RUN ln -s /usr/local/bin/pip3 /usr/bin/pip3

## Install virtualenv because venv doesn't come with Python
## Install AWS CLI, NLTK, NLTK_DATA, numpy, tinysegmenter
RUN pip2 install -qqq virtualenv lxml awscli nltk tinysegmenter numpy
RUN pip3 install -qqq virtualenv lxml awscli nltk tinysegmenter numpy

########
## Install Yarn & NodeJS
RUN curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
RUN yum -y install nodejs yarn

## Grab some commonly used packages
RUN mkdir /packages && wget --directory-prefix=/packages --no-verbose --no-check-certificate 'https://github.com/Miserlou/lambda-packages/files/1425358/_sqlite3.so.zip'
RUN unzip /packages/_sqlite3.so.zip -d /packages
# Cleanup
RUN rm -rf /packages/__MACOSX /packages/_sqlite3.so.zip

CMD ["/bin/bash"]
