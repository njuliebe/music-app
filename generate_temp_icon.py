#!/usr/bin/env python3
"""
临时图标生成器 - 为 MusicX 生成简单的应用图标
需要安装: pip install pillow
"""

from PIL import Image, ImageDraw
import os

def create_icon(size=1024):
    """创建一个简单的应用图标"""
    # 创建一个新的RGBA图像
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 定义颜色
    purple1 = (139, 127, 232)  # #8B7FE8
    purple2 = (99, 102, 241)   # #6366F1
    background = (26, 22, 37)  # #1A1625

    # 绘制圆角矩形背景
    corner_radius = int(size * 0.22)

    # 创建渐变背景（简化版 - 使用单色）
    draw.rounded_rectangle(
        [(0, 0), (size, size)],
        radius=corner_radius,
        fill=purple1
    )

    # 绘制中心的音符符号（简化版 - 使用圆形代表）
    center_x = size // 2
    center_y = size // 2
    note_size = int(size * 0.3)

    # 绘制音符圆圈
    draw.ellipse(
        [center_x - note_size, center_y - note_size,
         center_x + note_size, center_y + note_size],
        fill=(255, 255, 255)
    )

    # 在圆圈中绘制简单的音符符号
    draw.ellipse(
        [center_x - note_size//2, center_y - note_size//2,
         center_x + note_size//2, center_y + note_size//2],
        fill=purple1
    )

    return img

def create_adaptive_foreground(size=1024):
    """创建Android自适应图标的前景"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 绘制白色音符
    center_x = size // 2
    center_y = size // 2
    note_size = int(size * 0.25)

    # 简单的音符形状
    draw.ellipse(
        [center_x - note_size, center_y - note_size,
         center_x + note_size, center_y + note_size],
        fill=(255, 255, 255)
    )

    return img

def main():
    # 创建assets/icon目录
    os.makedirs('assets/icon', exist_ok=True)

    # 生成主图标
    print("Generating main app icon...")
    main_icon = create_icon(1024)
    main_icon.save('assets/icon/app_icon.png', 'PNG')
    print("✓ Main icon saved to assets/icon/app_icon.png")

    # 生成Android自适应前景图标
    print("Generating adaptive foreground icon...")
    foreground_icon = create_adaptive_foreground(1024)
    foreground_icon.save('assets/icon/app_icon_foreground.png', 'PNG')
    print("✓ Foreground icon saved to assets/icon/app_icon_foreground.png")

    print("\n✅ Icons generated successfully!")
    print("Now run: flutter pub run flutter_launcher_icons")

if __name__ == "__main__":
    try:
        main()
    except ImportError:
        print("❌ Error: Pillow library not installed")
        print("Please run: pip install pillow")
    except Exception as e:
        print(f"❌ Error: {e}")