#!/bin/bash

# 设置定时任务脚本
# 每天凌晨2点执行数据清理

SCRIPT_DIR="/home/code/ethereum-node"
CLEANUP_SCRIPT="$SCRIPT_DIR/cleanup-old-data.sh"
CRON_LOG="$SCRIPT_DIR/logs/cron.log"

# 创建日志目录
mkdir -p "$(dirname "$CRON_LOG")"

# 给脚本执行权限
chmod +x "$CLEANUP_SCRIPT"

# 创建cron任务
CRON_JOB="0 2 * * * $CLEANUP_SCRIPT >> $CRON_LOG 2>&1"

# 检查是否已经存在相同的cron任务
if crontab -l 2>/dev/null | grep -q "$CLEANUP_SCRIPT"; then
    echo "定时任务已存在，跳过设置"
else
    # 添加新的cron任务
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "已设置定时任务：每天凌晨2点执行数据清理"
fi

# 显示当前的cron任务
echo "当前的cron任务："
crontab -l

echo ""
echo "定时任务设置完成！"
echo "清理脚本将每天凌晨2点自动执行"
echo "日志文件位置: $CRON_LOG" 