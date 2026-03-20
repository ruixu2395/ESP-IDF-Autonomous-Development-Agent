# 硬件与软件映射

## 1. 总线与器件

| 总线/接口 | 硬件器件 | 软件模块建议 |
|---|---|---|
| FSPI | GC9A01 圆屏、W25Q128 外部 Flash | `driver_lcd_gc9a01`、`driver_flash_w25q128` |
| I2C0 | TM1021Z-7(CST816系) 触摸、QMI8658C IMU | `driver_touch_cst816`、`driver_imu_qmi8658` |
| I2S0 | 外接 MEMS Mic | `driver_i2s_capture` |
| I2S1 | 外接 I2S DAC + Speaker | `driver_i2s_playback` |
| UART0 | Type-C 转串口（115200） | `esp_log` 输出通道 |
| ADC1 | BAT_ADC 分压采样 | `driver_battery_adc` |
| GPIO | Key1/Key2、LCD 控制线（BL/DC/RST） | `driver_gpio_keys`、`driver_lcd_ctrl` |

## 2. 架构层映射

| 层级 | 核心模块 | 说明 |
|---|---|---|
| L4 应用层 | `app_main`、`app_ui`、`app_voice`、`app_power` | 状态机和用户逻辑 |
| L3 中间件层 | `mid_lvgl`、`mid_audio`、`mid_wifi` | 图形、音频、网络|
| L2 驱动层 | SPI/I2C/I2S/UART/ADC 各 driver | 调用 ESP-IDF 官方接口实现驱动，并向 mid 层提供统一接口 |
| L1 硬件层 | ESP32-S3 + 外围器件 | 原理图定义的实体设备 |

## 3. 开发注意点

- FSPI 同时挂 LCD 和外部 Flash，先明确片选与时序，再做并发访问策略。
- I2C0 同时挂触摸与 IMU，初始化阶段按地址探测并做失败降级。
- 音箱相关器件为外接扩展模块，音频链路开发时先验证外设接入和供电。
- 具体 GPIO 号以 `原理图.jpg` 与板级配置为准，编码前先核对网络名。
- driver 层优先复用 ESP-IDF 官方 API（`esp_lcd`、`i2c_master`、`i2s_std`、`esp_adc` 等），避免重复造轮子。
