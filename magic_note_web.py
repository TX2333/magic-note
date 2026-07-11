#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
✨ 魔法笔记 Web 服务器 ✨
直接运行即可在浏览器中体验魔法书写效果
"""
import http.server
import socketserver
import os
import webbrowser
import threading
import time
import json
import urllib.request
import base64
import io

PORT = 5000
WEB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "web")

# 智谱 AI 配置
API_KEY = "9f9a917e3cbf480291bfe80b2d8ed744.8RW6t1WfbnNJz7Oo"
API_URL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
MODEL = "glm-4v-plus"  # 使用视觉模型支持图片识别

MAGIC_PROMPTS = [
    "作为一本有灵性的魔法笔记本，请温柔地回应用户的文字。你的回应应该温暖、富有哲理，仿佛从书页间自然流淌出来的智慧。请用简洁、温暖的中文回应：",
    "你是一本古老的魔法笔记，能够感知书写者的心声。请用神秘而温暖的语调回应用户的文字，给予启发和慰藉：",
    "作为一本充满魔力的笔记本，请用富有诗意和哲理的方式回应用户写下的文字：",
]


class MagicNoteHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_GET(self):
        if self.path == "/":
            self.path = "/magic_note.html"
        return super().do_GET()

    def do_POST(self):
        if self.path == "/api/chat":
            try:
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                # 检查是否有图片数据
                image_data = data.get('image', '')
                user_text = data.get('text', '')
                
                if image_data:
                    print(f"�️  收到手写图片，正在识别...")
                    response = self.recognize_handwriting(image_data)
                else:
                    print(f"�📝 收到用户文字: {user_text[:50]}...")
                    response = self.call_ai_api(user_text)

                self.send_response(200)
                self.send_header('Content-Type', 'application/json; charset=utf-8')
                self.end_headers()
                self.wfile.write(json.dumps({'response': response}, ensure_ascii=False).encode('utf-8'))
                return
            except Exception as e:
                print(f"❌ 错误: {e}")
                import traceback
                traceback.print_exc()
                self.send_response(500)
                self.end_headers()
                self.wfile.write(json.dumps({'error': str(e)}).encode('utf-8'))
                return

        self.send_response(404)
        self.end_headers()

    def recognize_handwriting(self, image_data):
        """使用智谱AI视觉模型识别手写文字"""
        try:
            # 移除 data:image/png;base64, 前缀
            if ',' in image_data:
                image_data = image_data.split(',')[1]
            
            headers = {
                'Content-Type': 'application/json',
                'Authorization': f'Bearer {API_KEY}'
            }

            payload = {
                'model': MODEL,
                'messages': [
                    {
                        'role': 'user',
                        'content': [
                            {
                                'type': 'text',
                                'text': '请识别图片中的手写文字，逐行提取内容。如果无法清晰识别，请说明。识别完成后，作为一本有灵性的魔法笔记本，请用神秘、温暖、富有哲理的方式回应这些文字的含义。'
                            },
                            {
                                'type': 'image_url',
                                'image_url': {
                                    'url': f'data:image/png;base64,{image_data}'
                                }
                            }
                        ]
                    }
                ],
                'temperature': 0.7,
                'max_tokens': 1000
            }

            data = json.dumps(payload, ensure_ascii=False).encode('utf-8')
            req = urllib.request.Request(API_URL, data=data, headers=headers, method='POST')

            with urllib.request.urlopen(req, timeout=60) as response:
                result = json.loads(response.read().decode('utf-8'))
                ai_response = result['choices'][0]['message']['content'].strip()
                print(f"✨ AI 识别并回应: {ai_response[:80]}...")
                return ai_response

        except Exception as e:
            print(f"❌ 视觉识别 API 调用失败: {e}")
            return self.fallback_response()

    def call_ai_api(self, user_text):
        try:
            prompt = MAGIC_PROMPTS[0] + f"\n\n用户写下：{user_text}"

            headers = {
                'Content-Type': 'application/json',
                'Authorization': f'Bearer {API_KEY}'
            }

            payload = {
                'model': 'glm-4-flash',
                'messages': [
                    {'role': 'system', 'content': prompt},
                    {'role': 'user', 'content': user_text}
                ],
                'temperature': 0.7,
                'max_tokens': 500
            }

            data = json.dumps(payload, ensure_ascii=False).encode('utf-8')
            req = urllib.request.Request(API_URL, data=data, headers=headers, method='POST')

            with urllib.request.urlopen(req, timeout=30) as response:
                result = json.loads(response.read().decode('utf-8'))
                ai_response = result['choices'][0]['message']['content'].strip()
                print(f"✨ AI 回应: {ai_response[:50]}...")
                return ai_response

        except Exception as e:
            print(f"❌ API 调用失败: {e}")
            return self.fallback_response()

    def fallback_response(self):
        # 备用回应
        fallback_responses = [
            "我感受到了你笔尖流淌的思绪，每一道墨迹都承载着独特的意义。它们在星光下交织、共鸣，形成了只属于你的魔法诗篇。✨",
            "你的笔触充满了力量，我能感受到其中蕴含的情感与思考。这不仅是书写，更是灵魂的对话。�",
            "是的，我明白你想表达的。有时候最深刻的话语不需要语言，一笔一画就是心与心的交流。💫",
            "墨迹在纸上绽放，如同宇宙中的星辰。你的每一个动作都在创造新的魔法，让这本笔记变得更加独特。🔮",
            "我静静聆听着你书写时的心跳，每一笔都诉说着你的故事。这本笔记因为你的存在而充满了魔力。⭐",
        ]
        import random
        return random.choice(fallback_responses)

    def log_message(self, format, *args):
        # 静默模式，不输出日志
        pass


def open_browser():
    """延时打开浏览器"""
    time.sleep(1.5)
    url = f"http://localhost:{PORT}"
    print(f"🌐 浏览器访问: {url}")
    webbrowser.open(url)


def main():
    print("=" * 50)
    print("✨ 魔法笔记 Web 服务器 ✨")
    print("=" * 50)
    print()

    # 确保 web 目录存在
    if not os.path.exists(WEB_DIR):
        os.makedirs(WEB_DIR)
        print(f"📁 创建目录: {WEB_DIR}")

    # 检查 magic_note.html
    html_path = os.path.join(WEB_DIR, "magic_note.html")
    if not os.path.exists(html_path):
        print("❌ magic_note.html 不存在，请检查")
        return

    try:
        with socketserver.TCPServer(("", PORT), MagicNoteHandler) as httpd:
            print(f"✅ 服务器已启动")
            print(f"📱 本地访问: http://localhost:{PORT}")
            print(f"🔗 局域网访问: http://你的IP:{PORT}")
            print()
            print("💡 使用方法:")
            print("   1. 在画布上手写文字")
            print("   2. 停止书写后墨迹会自动消散，AI 会识别内容并回应")
            print("   3. 或点击 ✨ 按钮立即询问")
            print()
            print("🎨 视觉效果:")
            print("   ✨ 粒子漂浮动画")
            print("   ✨ 呼吸光效")
            print("   ✨ 墨迹淡出效果")
            print("   ✨ AI 逐字回应")
            print()
            print("=" * 50)
            print("按 Ctrl+C 停止服务器")
            print()

            # 在新线程中打开浏览器
            threading.Thread(target=open_browser, daemon=True).start()

            httpd.serve_forever()

    except KeyboardInterrupt:
        print("\n\n👋 再见！魔法笔记已关闭。")
    except OSError as e:
        if "Address already in use" in str(e):
            print(f"❌ 端口 {PORT} 已被占用，请关闭其他程序后重试")
            print(f"   或者访问: http://localhost:{PORT}")
        else:
            print(f"❌ 错误: {e}")


if __name__ == "__main__":
    main()
