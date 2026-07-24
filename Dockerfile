FROM python:3.13-alpine

# نصب پکیج‌های مورد نیاز
RUN apk add --no-cache zip unzip ffmpeg whois openssh bash-completion bash git build-base binutils

# تنظیم پسورد روت (در صورت نیاز به لاگین مستقیم روت با پسورد)
# پسورد روت به rootpassword تغییر می‌یابد؛ می‌توانید آن را عوض کنید
RUN echo "root:rootpassword" | chpasswd

# ساخت ساختار مورد نیاز SSH
RUN mkdir -p /var/run/sshd && chmod 0755 /var/run/sshd
RUN ssh-keygen -A

# تنظیمات SSH:
# 1. فعال‌سازی دسترسی روت
# 2. غیرفعال‌سازی تخصیص TTY (جلوگیری از باز شدن کنسول و ترمینال)
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "PermitTTY no" >> /etc/ssh/sshd_config

# ساخت اسکریپت ورودی برای اجرای SSHD روی پورت 8080
RUN echo -e '#!/bin/sh\n\
exec /usr/sbin/sshd -D -o Port=8080' > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
