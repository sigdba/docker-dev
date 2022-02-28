FROM python:3.9.9-slim AS base

RUN case $(uname -m) in \
    x86_64) SM_ARCH=64bit; CW_ARCH=amd64 ;; \
    aarch64) SM_ARCH=arm64; CW_ARCH=arm64 ;; \
    *) echo "UNKNOWN ARCH: $(uname -m)"; exit 1 ;; \
    esac \
 && sed -i 's:^path-exclude /usr/share/groff/\*::' /etc/dpkg/dpkg.cfg.d/docker \
 && apt-get update \
 && apt-get install -y git wget curl nmap zsh groff vim entr sudo jq parallel unzip make \
 && sed -i 's/^%sudo.*/%sudo ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers \
 && pip install --upgrade pip \
 && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY requirements.txt /build/
RUN pip install -Ur /build/requirements.txt --no-cache-dir

COPY site.conf .docker-dev /build/
RUN mkdir -p /home/user \
 && cp -f /build/docker_zshrc.sh /home/user/.zshrc \
 && cp -f /build/docker_profile.sh /etc/profile.d/docker_dev.sh \
 && cp -f /build/docker_launch.sh /launch.sh

RUN chmod 755 /build/add_features.sh \
 && /build/add_features.sh

# TEMPORARY: https://github.com/Sceptre/sceptre/issues/1180
# RUN chmod -R a+rw /usr/local/lib/python3.8/site-packages
# TODO: Move this into a script so that the hard-coded 3.9 can come out
COPY .docker-dev/sceptre_patch_update.py /usr/local/lib/python3.9/site-packages/sceptre/cli/update.py
