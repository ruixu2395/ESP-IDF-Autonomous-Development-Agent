# GPIO 引脚映射表 (ESP32-S3-Touch-LCD-1.28)

> 已根据原理图完成所有 GPIO 编号填写。
> 格式：`GPIO_NUM_xx`，未使用填 `-1`。

---

## 1. LCD (GC9A01) — SPI/FSPI

| 信号 | 说明 | GPIO 编号 |
|------|------|-----------|
| LCD_CLK | SPI 时钟 (SCLK) | `GPIO_NUM_10` |
| LCD_MOSI | SPI 数据  | `GPIO_NUM_11` |
| LCD_MISO | SPI 数据  | `GPIO_NUM_12` |
| LCD_CS | 片选 | `GPIO_NUM_9` |
| LCD_DC | 数据/命令选择 | `GPIO_NUM_8` |
| LCD_RST | 复位 | `GPIO_NUM_14` |
| LCD_BL | 背光控制 | `GPIO_NUM_2` |

---

## 2. 触摸控制器 (CST816) — I2C0

| 信号 | 说明 | GPIO 编号 |
|------|------|-----------|
| TP_SDA | I2C 数据 | `GPIO_NUM_6` |
| TP_SCL | I2C 时钟 | `GPIO_NUM_7` |
| TP_INT | 触摸中断 | `GPIO_NUM_5` |
| TP_RST | 触摸复位 | `GPIO_NUM_13` |

> **I2C 地址（7-bit）**：CST816 确认为 `0x15`。

---

## 3. IMU (QMI8658C) — I2C0（与触摸共用总线）

| 信号 | 说明 | GPIO 编号 |
|------|------|-----------|
| IMU_SDA | I2C 数据（同 TP_SDA） | `GPIO_NUM_6` |
| IMU_SCL | I2C 时钟（同 TP_SCL） | `GPIO_NUM_7` |
| IMU_INT1 | 中断1 | `GPIO_NUM_4` |
| IMU_INT2 | 中断2 | `GPIO_NUM_3` |

> **I2C 地址（7-bit）**：QMI8658C 的 SA0 接地，地址为 `0x6A`。

---

## 4. 外部 Flash (W25Q128) — FSPI（与 LCD 共用总线）

| 信号 | 说明 | GPIO 编号 |
|------|------|-----------|
| FLASH_CLK | SPI 时钟（同 LCD_CLK） | `GPIO_NUM_10` |
| FLASH_MOSI | SPI MOSI（同 LCD_MOSI） | `GPIO_NUM_11` |
| FLASH_MISO | SPI MISO | `GPIO_NUM_12` |
| FLASH_CS | 片选（独立） | `GPIO_NUM_47` |

---

## 5. 物理按键

| 信号 | 说明 | GPIO 编号 |
|------|------|-----------|
| KEY1 | 唤醒 / 功能键1 | `GPIO_NUM_0` |
| KEY2 | 功能键2 | `GPIO_NUM_14` |

---

## 6. 电池 ADC

| 信号 | 说明 | GPIO 编号 / 通道 |
|------|------|-----------------|
| BAT_ADC | 电池电压分压采样 | `GPIO_NUM_1` (ADC1_CH0) |

---

## 7. I2S 音频（外接扩展，GPIO_OUT 接口）

| 信号 | 说明 | GPIO 编号 |
|------|------|-----------|
| I2S_MIC_BCLK | 麦克风位时钟 | `GPIO_NUM_15` |
| I2S_MIC_WS | 麦克风字选 | `GPIO_NUM_16` |
| I2S_MIC_DIN | 麦克风数据输入 | `GPIO_NUM_17` |
| I2S_SPK_BCLK | 扬声器位时钟 | `GPIO_NUM_18` |
| I2S_SPK_WS | 扬声器字选 | `GPIO_NUM_21` |
| I2S_SPK_DOUT | 扬声器数据输出 | `GPIO_NUM_48` |

---

## 8. 备注

- **总线复用**：LCD 与 Flash 共用 SPI 引脚（10, 11, 12），通过各自的 CS 引脚（9, 47）区分。
- **I2C0 总线**：触摸和 IMU 共用 GPIO6/7。
- **LDO 控制**：原理图显示 `GPIO45` 涉及电源使能，初始化时需拉高以确保外设供电。
- **背光**：`GPIO40` 接 PWM 通道可调节亮度。