FROM alpine:3.16

# UserId and Password are set through 
ENV user
ENV password

# Set the working directory to /login
WORKDIR /login

# Copy login bash script
COPY ./static/script script

# Add unpriviliged user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /app \
    && apk add --no-cache gcc

USER appuser

RUN apk update \
    && apk upgrade
RUN cd login \
    && chmod +x ./script \
    && echo "*/5 * * * * /login/script $user $password" > /etc/crontabs/appuser \
    && crond -l 2 -f > /dev/stdout 2> /dev/stderr \
    && rc-service crond start
    && rc-update add crond

ENTRYPOINT ["/bin/sh"]
CMD["run-parts --test /etc/periodic/15min"]