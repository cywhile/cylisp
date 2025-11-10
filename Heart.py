import tkinter as tk
from tkinter import messagebox
import random
import math
import time

# 温馨提示语列表（可自定义修改）
MESSAGES = [
    "好  好吃饭", "我想你了", "天天开心", "保持好心情",
    "天冷了多穿衣服", "好好爱自己", "多喝热水~", "别熬夜",
    "记得想我", "你是最棒的", "照顾好自己", "注意休息"
]

# 柔和的心形颜色
HEART_COLORS = ["#ffb6c1", "#ffc0cb", "#ff69b4", "#ff1493", "#db7093"]
# 便签背景色
NOTE_COLORS = ["#fff0f5", "#fffacd", "#f0fff0", "#f0f8ff", "#f8f8ff", "#fff5ee"]

class HeartMessageApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.withdraw()  # 隐藏主窗口
        self.screen_width = self.root.winfo_screenwidth()
        self.screen_height = self.root.winfo_screenheight()
        self.all_windows = []
        
    def generate_heart_points(self, scale=15, offset_x=None, offset_y=None):
        """生成正方向爱心轮廓坐标点"""
        if offset_x is None:
            offset_x = self.screen_width // 2
        if offset_y is None:
            offset_y = self.screen_height // 2 - 50
            
        points = []
        for t in range(0, 360, 2):  # 步长为2度，更平滑
            rad = math.radians(t)
            # 修正爱心方程，确保是正方向
            x = 16 * math.sin(rad) ** 3
            y = -(13 * math.cos(rad) - 5 * math.cos(2 * rad) - 2 * math.cos(3 * rad) - math.cos(4 * rad))
            points.append((offset_x + x * scale, offset_y + y * scale))
        return points
    
    def create_note_window(self, x, y, text, is_heart=False):
        """创建便签窗口"""
        try:
            win = tk.Toplevel(self.root)
            win.overrideredirect(True)
            
            # 设置窗口位置和大小
            width = 120 if is_heart else 100
            height = 35 if is_heart else 30
            
            win.geometry(f"{width}x{height}+{int(x)}+{int(y)}")
            
            # 设置颜色
            if is_heart:
                bg_color = random.choice(HEART_COLORS)
            else:
                bg_color = random.choice(NOTE_COLORS)
                
            win.configure(bg=bg_color)
            
            # 添加阴影效果
            win.wm_attributes("-alpha", 0.95)
            
            # 创建标签
            label = tk.Label(
                win, 
                text=text, 
                bg=bg_color, 
                fg="#333333", 
                font=("微软雅黑", 10, "bold"),
                wraplength=110
            )
            label.pack(fill="both", expand=True, padx=8, pady=6)
            
            # 添加鼠标悬停效果
            def on_enter(e):
                win.configure(bg="#ffffff")
                label.configure(bg="#ffffff")
                
            def on_leave(e):
                win.configure(bg=bg_color)
                label.configure(bg=bg_color)
                
            label.bind("<Enter>", on_enter)
            label.bind("<Leave>", on_leave)
            
            # 添加点击关闭功能
            def on_click(e):
                win.destroy()
                if win in self.all_windows:
                    self.all_windows.remove(win)
                    
            label.bind("<Button-1>", on_click)
            
            return win
            
        except Exception as e:
            return None
    
    def create_heart_animation(self):
        """创建正方向爱心动画"""
        heart_points = self.generate_heart_points(
            scale=20, 
            offset_x=self.screen_width//2, 
            offset_y=self.screen_height//2
        )
        
        heart_windows = []
        
        # 第一阶段：绘制爱心轮廓
        print("正在绘制爱心轮廓...")
        for i, (x, y) in enumerate(heart_points):
            if i % 3 == 0:  # 减少密度，提高性能
                tip = MESSAGES[i % len(MESSAGES)]
                win = self.create_note_window(x, y, tip, is_heart=True)
                if win:
                    heart_windows.append(win)
                    self.all_windows.append(win)
                    self.root.update()
                    time.sleep(0.02)
        
        # 第二阶段：填充爱心内部
        print("正在填充爱心内部...")
        for _ in range(30):
            center_x = self.screen_width // 2
            center_y = self.screen_height // 2
            
            # 在爱心区域内随机生成点
            for _ in range(8):
                # 使用极坐标在爱心形状内生成点
                angle = random.uniform(0, 2 * math.pi)
                radius = random.uniform(0, 1)  # 归一化半径
                
                # 爱心参数方程
                x_param = 16 * math.sin(angle) ** 3
                y_param = -(13 * math.cos(angle) - 5 * math.cos(2 * angle) - 2 * math.cos(3 * angle) - math.cos(4 * angle))
                
                # 缩放并转换为屏幕坐标
                x = center_x + x_param * 20
                y = center_y + y_param * 20
                
                # 确保在屏幕范围内
                if 0 < x < self.screen_width - 100 and 0 < y < self.screen_height - 50:
                    tip = random.choice(MESSAGES)
                    win = self.create_note_window(x, y, tip, is_heart=True)
                    if win:
                        heart_windows.append(win)
                        self.all_windows.append(win)
            
            self.root.update()
            time.sleep(0.05)
        
        # 显示爱心3秒
        print("爱心显示中...")
        time.sleep(3)
        
        # 渐隐效果关闭爱心
        print("渐隐关闭爱心...")
        for alpha in range(95, 0, -5):
            for win in heart_windows:
                try:
                    if win.winfo_exists():
                        win.wm_attributes("-alpha", alpha/100)
                except:
                    pass
            self.root.update()
            time.sleep(0.05)
        
        # 关闭爱心窗口
        for win in heart_windows:
            try:
                if win.winfo_exists():
                    win.destroy()
            except:
                pass
        
        # 从总列表中移除
        for win in heart_windows:
            if win in self.all_windows:
                self.all_windows.remove(win)
                
        print("爱心动画完成")
    
    def create_full_screen_notes(self):
        """创建满屏便签"""
        print("创建满屏便签...")
        note_count = min(100000, (self.screen_width // 150) * (self.screen_height // 40))
        
        for i in range(note_count):
            x = random.randint(50, self.screen_width - 150)
            y = random.randint(50, self.screen_height - 50)
            tip = random.choice(MESSAGES)
            
            win = self.create_note_window(x, y, tip)
            if win:
                self.all_windows.append(win)
                
            # 分批更新，提高性能
            if i % 10 == 0:
                self.root.update()
                time.sleep(0.01)
        
        self.root.update()
        print("满屏便签完成")
    
    def add_floating_notes(self):
        """持续添加浮动便签"""
        def add_note():
            if len(self.all_windows) < 80:  # 限制总数
                x = random.randint(50, self.screen_width - 150)
                y = random.randint(50, self.screen_height - 50)
                tip = random.choice(MESSAGES)
                
                win = self.create_note_window(x, y, tip)
                if win:
                    self.all_windows.append(win)
            
            # 随机间隔添加新便签
            self.root.after(random.randint(3000, 6000), add_note)
        
        add_note()
    
    def show_close_button(self):
        """显示关闭按钮"""
        close_win = tk.Toplevel(self.root)
        close_win.overrideredirect(True)
        close_win.configure(bg="#ff4444", bd=2, relief="raised")
        close_win.geometry(f"80x30+{self.screen_width-100}+20")
        close_win.wm_attributes("-alpha", 0.9)
        
        close_btn = tk.Label(
            close_win, 
            text="关闭", 
            bg="#ff4444", 
            fg="white", 
            font=("微软雅黑", 10, "bold"),
            cursor="hand2"
        )
        close_btn.pack(fill="both", expand=True)
        
        def close_all(event):
            for win in self.all_windows[:]:
                try:
                    if isinstance(win, tk.Toplevel) and win.winfo_exists():
                        win.destroy()
                except:
                    pass
            close_win.destroy()
            self.root.quit()
        
        close_btn.bind("<Button-1>", close_all)
        self.all_windows.append(close_win)
    
    def run(self):
        """运行主程序"""
        try:
            # 显示开始提示
            messagebox.showinfo("温馨提示", "即将显示爱心消息，请欣赏！")
            
            # 显示主窗口
            self.root.deiconify()
            self.root.title("爱心便签")
            self.root.geometry(f"300x120+{self.screen_width//2-150}+{self.screen_height//2-60}")
            self.root.configure(bg="#f0f0f0")
            
            # 添加控制按钮
            control_frame = tk.Frame(self.root, bg="#f0f0f0")
            control_frame.pack(expand=True, fill="both", padx=20, pady=20)
            
            title_label = tk.Label(
                control_frame,
                text="💖 爱心消息程序 💖",
                font=("微软雅黑", 14, "bold"),
                bg="#f0f0f0",
                fg="#ff69b4"
            )
            title_label.pack(pady=(0, 10))
            
            start_btn = tk.Button(
                control_frame,
                text="开始显示爱心",
                command=self.start_animation,
                font=("微软雅黑", 12),
                bg="#ff69b4",
                fg="white",
                relief="raised",
                bd=3
            )
            start_btn.pack(fill="x", pady=5)
            
            exit_btn = tk.Button(
                control_frame,
                text="退出程序",
                command=self.root.quit,
                font=("微软雅黑", 12),
                bg="#666",
                fg="white",
                relief="raised",
                bd=3
            )
            exit_btn.pack(fill="x", pady=5)
            
            self.root.mainloop()
            
        except Exception as e:
            messagebox.showerror("错误", f"程序运行出错: {str(e)}")
    
    def start_animation(self):
        """开始动画序列"""
        self.root.withdraw()  # 隐藏控制窗口
        
        # 执行动画序列
        self.create_heart_animation()
        self.create_full_screen_notes()
        self.add_floating_notes()
        self.show_close_button()

if __name__ == "__main__":
    app = HeartMessageApp()
    app.run()