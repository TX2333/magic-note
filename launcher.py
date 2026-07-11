#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
✨ 魔法笔记 - Magic Note 启动器
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

# 项目根目录
PROJECT_ROOT = Path(__file__).parent


def check_flutter():
    """检查Flutter是否安装"""
    try:
        result = subprocess.run(
            ['flutter', '--version'],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        if result.returncode == 0:
            print("✅ Flutter已安装")
            return True
    except FileNotFoundError:
        pass
    print("❌ Flutter未安装，请先安装Flutter SDK")
    return False


def check_dependencies():
    """检查Flutter依赖"""
    print("\n📦 检查依赖...")
    try:
        result = subprocess.run(
            ['flutter', 'pub', 'get'],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        if result.returncode == 0:
            print("✅ 依赖安装完成")
            return True
    except Exception as e:
        print(f"❌ 依赖检查失败: {e}")
        return False


def run_flutter_app(target_device=None, release_mode=False):
    """运行Flutter应用"""
    print("\n🚀 启动魔法笔记...")
    print("✨ 愿古老的智慧与你同在")
    
    cmd = ['flutter', 'run']
    
    if release_mode:
        cmd.append('--release')
    
    if target_device:
        cmd.extend(['-d', target_device])
    
    try:
        subprocess.run(cmd, cwd=PROJECT_ROOT)
    except KeyboardInterrupt:
        print("\n👋 魔法已封存")
    except Exception as e:
        print(f"❌ 启动失败: {e}")


def build_apk(output_path=None, release_mode=True):
    """构建APK"""
    print("\n� 正在编织魔法APK...")
    
    cmd = ['flutter', 'build', 'apk']
    
    if release_mode:
        cmd.append('--release')
    else:
        cmd.append('--debug')
    
    try:
        result = subprocess.run(cmd, cwd=PROJECT_ROOT)
        if result.returncode == 0:
            apk_path = PROJECT_ROOT / 'build' / 'app' / 'outputs' / 'flutter-apk'
            print(f"\n✨ APK魔法编织完成!")
            print(f"📂 输出目录: {apk_path}")
            
            if output_path:
                import shutil
                output_dir = Path(output_path)
                output_dir.mkdir(parents=True, exist_ok=True)
                
                for apk_file in apk_path.glob('*.apk'):
                    dest = output_dir / apk_file.name
                    shutil.copy2(apk_file, dest)
                    print(f"📋 已复制到: {dest}")
    except Exception as e:
        print(f"❌ 魔法编织失败: {e}")


def list_devices():
    """列出可用设备"""
    print("\n📱 可用设备列表:")
    try:
        subprocess.run(['flutter', 'devices'], cwd=PROJECT_ROOT)
    except Exception as e:
        print(f"❌ 获取设备列表失败: {e}")


def show_ai_config():
    """显示AI配置"""
    print("\n🤖 魔法源泉 (AI配置):")
    print("=" * 50)
    print("【GLM-4-Flash】")
    print("API Base: https://open.bigmodel.cn/api/paas/v4")
    print("Model: glm-4-flash")
    print()
    print("【Moonshot】")
    print("API Base: https://api.moonshot.cn/v1")
    print("Model: moonshot-v1-32k")
    print("=" * 50)
    print("\n✨ 双AI模型已内置，书写即触发魔法!")


def print_welcome():
    """打印欢迎信息"""
    print("""
╔═════════════════════════════════════════════════╗
║                                                 ║
║        ✨ 魔法笔记 - Magic Note ✨               ║
║                                                 ║
║      写字即有回应，一本有灵性的笔记。              ║
║                                                 ║
╚═════════════════════════════════════════════════╝
    """)
    print(f"📂 项目目录: {PROJECT_ROOT.absolute()}")


def main():
    parser = argparse.ArgumentParser(
        description='✨ 魔法笔记启动器',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用示例:
  python launcher.py              # 运行应用
  python launcher.py --devices    # 查看可用设备
  python launcher.py --build      # 构建APK
  python launcher.py --config     # 查看AI配置
        """
    )
    
    parser.add_argument('--devices', '-l', action='store_true',
                       help='列出可用设备')
    parser.add_argument('--device', '-d', type=str,
                       help='指定运行设备ID')
    parser.add_argument('--build', '-b', action='store_true',
                       help='构建APK')
    parser.add_argument('--release', '-r', action='store_true',
                       help='以Release模式运行/构建')
    parser.add_argument('--output', '-o', type=str,
                       help='APK输出目录')
    parser.add_argument('--config', '-c', action='store_true',
                       help='显示AI配置')
    parser.add_argument('--no-dep-check', action='store_true',
                       help='跳过依赖检查')
    
    args = parser.parse_args()
    
    print_welcome()
    
    # 显示AI配置
    if args.config:
        show_ai_config()
        return
    
    # 检查Flutter
    if not check_flutter():
        sys.exit(1)
    
    # 列出设备
    if args.devices:
        list_devices()
        return
    
    # 跳过依赖检查
    if not args.no_dep_check:
        check_dependencies()
    
    # 构建APK
    if args.build:
        build_apk(args.output, release_mode=args.release)
        return
    
    # 运行应用
    run_flutter_app(target_device=args.device, release_mode=args.release)


if __name__ == '__main__':
    main()
