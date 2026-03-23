#!/bin/bash
timedatectl set-timezone Asia/Shanghai

cat << 'EOF' > /root/do_update.sh
#!/bin/bash
echo "=== 开始更新: $(date) ==="
if flock -n /tmp/remnawave-update.lock bash <(curl -fsSL https://raw.githubusercontent.com/Mikimiya/remnawave-node/main/install.sh) update; then
echo "=== 更新成功: $(date) ==="
else
echo "=== 更新失败或已有任务在运行: $(date) ==="
fi
echo "----------------------------------------"
EOF

chmod +x /root/do_update.sh

RAND_MIN=$((RANDOM % 60))

cat << EOF > /etc/cron.d/remnawave-update
${RAND_MIN} 4 * * * root /root/do_update.sh >> /root/remnawave_update.log 2>&1
EOF

chmod 644 /etc/cron.d/remnawave-update
systemctl restart cron

echo "----------------------------------------"
echo "✅ 独立更新脚本已生成: /root/do_update.sh"
echo "✅ 自动更新定时任务已成功配置！"
printf "🕒 这台机器的更新时间被随机分配在: 每天北京时间 04:%02d\n" "$RAND_MIN"
echo "📄 日志文件: /root/remnawave_update.log"
echo "----------------------------------------"
