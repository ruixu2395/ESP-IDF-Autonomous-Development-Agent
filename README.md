# ESP-IDF Skills README

这个仓库当前包含 1 个可复用的 Codex skill：

* `esp32-smart-speaker-terminal-dev`：面向 Windows + PowerShell 的 ESP-IDF 开发闭环，覆盖需求解析、代码修改、构建、烧录、串口日志读取和硬件联调。

## 目录结构

```text
ESP-IDF-Autonomous-Development-Agent/
|- README.md
`- esp32-smart-speaker-terminal-dev/
   |- SKILL.md
   |- idf_env.ps1
   |- build_idf.ps1
   |- read_serial.ps1
   `- references/
```

## 使用方式

1. 把 skill 目录放到 Codex 可发现的位置，例如：
   * `%CODEX_HOME%\skills\esp32-smart-speaker-terminal-dev`
   * `%USERPROFILE%\.codex\skills\esp32-smart-speaker-terminal-dev`
2. 准备 ESP-IDF 环境变量：
   * `ESP_IDF_PROJECT_DIR`：目标工程目录
   * `IDF_PATH`
   * `IDF_TOOLS_PATH`
   * `IDF_PYTHON_DIR`：可选，不填时脚本会尝试自动探测
   * `ESP_PORT`：烧录/监控时使用
   * `ESP_CHIP`：可选，默认 `esp32s3`
3. 在对话里直接提出任务，例如：
   * “读取 references/架构.md 和 references/requirements.md，给我一个实现计划。”
   * “开始开发这个 ESP-IDF 功能，并完成 build、flash、monitor。”
   * “根据串口日志继续排查这个 ESP32-S3 的启动异常。”

## 自带脚本

`build_idf.ps1` 用于构建、烧录和 monitor：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\esp32-smart-speaker-terminal-dev\build_idf.ps1" -ProjectPath "<PROJECT_PATH>" -Action build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\esp32-smart-speaker-terminal-dev\build_idf.ps1" -ProjectPath "<PROJECT_PATH>" -Action flash -Port "<PORT>"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\esp32-smart-speaker-terminal-dev\build_idf.ps1" -ProjectPath "<PROJECT_PATH>" -Action flash-monitor -Port "<PORT>"
```

`read_serial.ps1` 用于复位后读取启动日志：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\esp32-smart-speaker-terminal-dev\read_serial.ps1" -ProjectPath "<PROJECT_PATH>" -Port "<PORT>" -Chip "esp32s3"
```

`idf_env.ps1` 是共享环境初始化脚本，`build_idf.ps1` 和 `read_serial.ps1` 会自动调用它。

## 已做的通用化处理

仓库内原先写死的本机路径和本机配置已替换为通用写法：

* 用户目录绝对路径改为 `<PROJECT_PATH>`、`%CODEX_HOME%`、`%USERPROFILE%` 或 `ESP_IDF_PROJECT_DIR`
* ESP-IDF 安装目录改为 `IDF_PATH`、`IDF_TOOLS_PATH`、`IDF_PYTHON_DIR`
* 固定串口号改为 `ESP_PORT` 或脚本参数 `-Port`
* 固定工程名改为按当前目标工程动态处理

## 建议

如果你后面继续往这个仓库里加 skill，保持每个 skill 至少包含：

* `SKILL.md`
* 必要脚本
* `references/` 里的任务背景资料

同时继续避免把用户名、桌面目录、磁盘盘符、串口号写死到 skill 内容里。
