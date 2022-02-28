FROM python:3.9.9-slim AS base

RUN sed -i 's:^path-exclude /usr/share/groff/\*::' /etc/dpkg/dpkg.cfg.d/docker \
 && apt-get update \
 && apt-get install -y git wget curl nmap zsh groff vim entr sudo jq parallel unzip make \
 && sed -i 's/^%sudo.*/%sudo ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers \
 && pip install --upgrade pip \
 && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# COPY requirements.txt /build/
# RUN pip install -Ur /build/requirements.txt --no-cache-dir

COPY . /build/
RUN mkdir -p /home/user \
 && cp -f /build/docker_zshrc.sh /home/user/.zshrc \
 && cp -f /build/docker_profile.sh /etc/profile.d/docker_dev.sh \
 && cp -f /build/docker_launch.sh /launch.sh

RUN chmod 755 /build/add_features.sh \
 && /build/add_features.sh
