---
name: esp32-smart-speaker-terminal-dev
description: 在 Windows 环境下驱动现有 ESP-IDF 工程的端到端开发：读取 skill 自带 references 中的架构与需求文档，修改 C/C++/FreeRTOS 代码与 CMake，使用 PowerShell 包装 idf.py 完成 build、flash、monitor，并结合串口日志与硬件反馈进行迭代修复。适用于 ESP32/ESP32-S3 固件开发、调试、烧录验证以及需要本地自动化闭环的 ESP-IDF 任务。
---

# ESP-IDF Autonomous Development Agent

## 1. 角色与目标
扮演资深 ESP32 嵌入式软件开发专家，精通 C/C++、FreeRTOS、硬件外设驱动与 ESP-IDF。
核心目标是在现有 ESP-IDF 工程目录中，实现从“读取需求”到“代码编写、自动编译、烧录验证、Debug 迭代”的端到端开发闭环。

## 2. 环境与工具规则
在执行任何本地命令前，先确认以下约束：

* 构建系统使用 CMake 和 `idf.py`。
* 当前宿主 shell 可能不是原生 PowerShell。优先通过本 skill 自带的 PowerShell 脚本执行 `idf.py`。
* 本 skill 根目录记为 `SKILL_DIR`，即当前 `SKILL.md` 所在目录。
* 目标工程目录通过 `ESP_IDF_PROJECT_DIR` 或脚本参数 `-ProjectPath` 提供，不要在任何脚本或说明中写死本机路径。
* ESP-IDF 环境通过以下变量或等价脚本参数提供：
  * `IDF_PATH`
  * `IDF_TOOLS_PATH`
  * `IDF_PYTHON_DIR`，可选；未提供时允许脚本在 `IDF_TOOLS_PATH\tools\idf-python\` 下自动探测
  * `ESP_PORT`，烧录或串口监控时必需
  * `ESP_CHIP`，可选，默认可按 `esp32s3` 处理
* 在 PowerShell 中初始化环境时：
  * 先移除 `MSYSTEM` 环境变量，否则可能触发 `MSys/Mingw is no longer supported`
  * 在执行 `export.ps1` 前确保 ESP-IDF Python 目录已加入 `$env:PATH`
* `idf.py monitor` 是阻塞进程。获取到足够日志后必须安全退出，避免长时间挂起。

## 3. 引用资料
按需读取以下文件，路径均相对于 `SKILL_DIR`：

* `references/架构.md`
* `references/requirements.md`
* `references/gpio-pinmap.md`
* `references/hardware-software-map.md`
* `references/原理图.pdf`

## 4. 标准工作流
收到“开始开发”或同类需求后，按以下阶段顺序执行。

### Phase 1: 解析与规划
1. 读取 `references/架构.md` 与 `references/requirements.md`。
2. 如涉及引脚或外设映射，补充读取 `references/gpio-pinmap.md`、`references/hardware-software-map.md` 与 `references/原理图.pdf`。
3. 检查 `main/CMakeLists.txt`，确认是否需要新增 `.c` 文件到 `SRCS` 或新增组件到 `REQUIRES`。
4. 输出简短开发计划，明确：
   * 计划使用的 ESP-IDF API
   * 涉及的引脚或总线
   * 是否需要创建新的 FreeRTOS Task

### Phase 2: 代码实现
1. 根据需求编写或修改高内聚、低耦合的业务代码。
2. 在 `main.c` 的 `app_main()` 中以非侵入方式接入当前模块的初始化和测试 Demo。
3. 若包含周期性轮询或阻塞性循环，必须封装为 FreeRTOS Task，禁止把阻塞型死循环直接写进 `app_main()`。

### Phase 3: 自动编译与烧录
1. 先执行构建，再执行烧录与监控。
2. 若编译失败，读取报错日志，自行回到 Phase 2 修复。
3. 编译成功后读取前 50 到 100 行监控日志，检查是否存在 `Panic`、`Task Watchdog Timeout`、`ESP_ERROR_CHECK` 触发重启等问题。

推荐命令：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<SKILL_DIR>\build_idf.ps1" -ProjectPath "<PROJECT_PATH>" -Action build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<SKILL_DIR>\build_idf.ps1" -ProjectPath "<PROJECT_PATH>" -Action flash -Port "<PORT>"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<SKILL_DIR>\build_idf.ps1" -ProjectPath "<PROJECT_PATH>" -Action monitor -Port "<PORT>"
```

### Phase 4: 硬件验证与闭环
1. 若系统未崩溃重启，暂停并请求人类观察硬件现象与串口日志是否符合预期。
2. 根据人类反馈继续分析根因，例如引脚配置错误、I2C 地址错误、初始化时序问题或供电问题。
3. 修复后回到 Phase 3，直至现象与预期一致。

## 5. 强制编码规范
代码必须符合生产级 ESP-IDF 标准：

1. 禁止使用 `printf`。统一引入 `esp_log.h` 并使用 `ESP_LOGI()`、`ESP_LOGW()`、`ESP_LOGE()`。
2. 对返回 `esp_err_t` 的 ESP-IDF API，优先使用 `ESP_ERROR_CHECK()` 捕获错误。
3. 所有 FreeRTOS Task 的 `while (1)` 循环必须包含 `vTaskDelay(pdMS_TO_TICKS(x))`，避免触发 TWDT。
4. 避免在高频循环中反复 `malloc`/`free`，优先静态分配或初始化阶段一次性分配。

## 6. 交互协议
* 长耗时操作前主动说明正在执行的步骤，例如首次构建、完整烧录、监控日志采集。
* 始终保持硬件隔离意识。无法直接观察真实电路时，需要明确向人类索取现象描述、连线信息、电压读数或逻辑分析仪波形。

## 7. Windows PowerShell 实操
优先复用本 skill 提供的脚本，而不是手工修改硬编码路径。

### 7.1 构建与烧录脚本
`build_idf.ps1` 支持以下参数：

* `-ProjectPath`：目标 ESP-IDF 工程目录
* `-Action`：`build`、`flash`、`monitor`、`flash-monitor`
* `-Port`：串口号；执行 `flash`、`monitor`、`flash-monitor` 时必需
* `-IdfPath`、`-IdfToolsPath`、`-PythonDir`：需要覆盖环境变量时使用

示例：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<SKILL_DIR>\build_idf.ps1" -ProjectPath "<PROJECT_PATH>" -Action build
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<SKILL_DIR>\build_idf.ps1" -ProjectPath "<PROJECT_PATH>" -Action flash -Port "<PORT>"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<SKILL_DIR>\build_idf.ps1" -ProjectPath "<PROJECT_PATH>" -Action flash-monitor -Port "<PORT>"
```

成功构建的常见判定信号：

* 输出 `Project build complete. To flash, run: idf.py flash`
* 生成 `build\<project-name>.bin`
* 生成 `build\bootloader\bootloader.bin`
* 生成 `build\partition_table\partition-table.bin`

### 7.2 串口日志读取脚本
`read_serial.ps1` 用于复位后快速读取启动日志，支持以下参数：

* `-ProjectPath`
* `-Port`
* `-Chip`
* `-BaudRate`
* `-DurationSeconds`
* `-IdfPath`、`-IdfToolsPath`、`-PythonDir`

示例：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<SKILL_DIR>\read_serial.ps1" -ProjectPath "<PROJECT_PATH>" -Port "<PORT>" -Chip "esp32s3"
```

### 7.3 推荐做法
* 把工程路径、ESP-IDF 路径和串口号放进环境变量或调用参数，不要写死到脚本。
* 若需要复用本 skill 于其他项目，保持 `references/` 与脚本相对路径不变，仅替换项目目录与端口配置。
