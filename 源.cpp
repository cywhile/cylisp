#include <iostream>
#include <Windows.h>
#include<string>
#include<thread>
#include <stdio.h>
#include<iomanip>
#include <vector>
#include <ctime>
#include <algorithm>
#pragma comment(lib, "winmm.lib")
using namespace std;



// 设置控制台光标可见性
void SetCursorVisibility(bool visible) {
    HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE);
    CONSOLE_CURSOR_INFO lpCursor;
    lpCursor.bVisible = visible;
    lpCursor.dwSize = 20;
    SetConsoleCursorInfo(console, &lpCursor);
}

// 设置控制台光标位置
void SetCursorPosition(int x, int y) {
    COORD coord;
    coord.X = x;
    coord.Y = y;
    SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), coord);
}

// 获取控制台大小
void GetConsoleSize(int& width, int& height) {
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);
    width = csbi.srWindow.Right - csbi.srWindow.Left + 1;
    height = csbi.srWindow.Bottom - csbi.srWindow.Top + 1;
}

// 烟花粒子结构
struct Particle {
    int x, y;
    int dx, dy;
    int color;
    int life;
    bool active;
};

// 烟花结构
struct Firework {
    int x, y;
    int height;
    int color;
    bool exploded;
    vector<Particle> particles;
};

// 生成随机数
int Random(int min, int max) {
    return min + rand() % (max - min + 1);
}

// 设置控制台颜色
void SetColor(int color) {
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    SetConsoleTextAttribute(hConsole, color);
}

// 重置颜色
void ResetColor() {
    SetColor(7);
}

// 初始化烟花
void InitFirework(Firework& fw, int width) {
    fw.x = Random(5, width - 5);
    fw.y = 0;
    fw.height = Random(5, 15);
    fw.color = Random(1, 15);
    fw.exploded = false;
    fw.particles.clear();
}

// 爆炸烟花
void ExplodeFirework(Firework& fw) {
    int particlesCount = Random(60, 100);
    for (int i = 0; i < particlesCount; i++) {
        Particle p;
        p.x = fw.x;
        p.y = fw.y;
        p.dx = Random(-1, 1);
        p.dy = Random(-1, 1);
        p.color = fw.color;
        p.life = Random(10, 20);
        p.active = true;
        fw.particles.push_back(p);
    }
    fw.exploded = true;
}

// 更新烟花
void UpdateFirework(Firework& fw) {
    if (!fw.exploded) {
        fw.y++;
        if (fw.y >= fw.height) {
            ExplodeFirework(fw);
        }
    }
    else {
        for (auto& p : fw.particles) {
            if (p.active) {
                p.x += p.dx;
                p.y += p.dy;
                p.life--;

                if (p.life <= 0 || p.x < 0 || p.y < 0) {
                    p.active = false;
                }
            }
        }
    }
}

// 绘制烟花
void DrawFirework(const Firework& fw) {
    if (!fw.exploded) {
        SetCursorPosition(fw.x, fw.y);
        SetColor(fw.color);
        cout << "*";
        ResetColor();
    }
    else {
        for (const auto& p : fw.particles) {
            if (p.active) {
                SetCursorPosition(p.x, p.y);
                SetColor(p.color);
                cout << ".";
                ResetColor();
            }
        }
    }
}

// 清除烟花
void ClearFirework(const Firework& fw) {
    if (!fw.exploded) {
        SetCursorPosition(fw.x, fw.y);
        cout << " ";
    }
    else {
        for (const auto& p : fw.particles) {
            if (p.active) {
                SetCursorPosition(p.x, p.y);
                cout << " ";
            }
        }
    }
}





// 音符定义 (MIDI音符编号)
enum Scale
{
    Rest = 0, C8 = 108, B7 = 107, A7s = 106, A7 = 105, G7s = 104, G7 = 103, F7s = 102, F7 = 101, E7 = 100,
    D7s = 99, D7 = 98, C7s = 97, C7 = 96, B6 = 95, A6s = 94, A6 = 93, G6s = 92, G6 = 91, F6s = 90, F6 = 89,
    E6 = 88, D6s = 87, D6 = 86, C6s = 85, C6 = 84, B5 = 83, A5s = 82, A5 = 81, G5s = 80, G5 = 79, F5s = 78,
    F5 = 77, E5 = 76, D5s = 75, D5 = 74, C5s = 73, C5 = 72, B4 = 71, A4s = 70, A4 = 69, G4s = 68, G4 = 67,
    F4s = 66, F4 = 65, E4 = 64, D4s = 63, D4 = 62, C4s = 61, C4 = 60, B3 = 59, A3s = 58, A3 = 57, G3s = 56,
    G3 = 55, F3s = 54, F3 = 53, E3 = 52, D3s = 51, D3 = 50, C3s = 49, C3 = 48, B2 = 47, A2s = 46, A2 = 45,
    G2s = 44, G2 = 43, F2s = 42, F2 = 41, E2 = 40, D2s = 39, D2 = 38, C2s = 37, C2 = 36, B1 = 35, A1s = 34,
    A1 = 33, G1s = 32, G1 = 31, F1s = 30, F1 = 29, E1 = 28, D1s = 27, D1 = 26, C1s = 25, C1 = 24, B0 = 23,
    A0s = 22, A0 = 21
};
enum Voice
{
    X1 = C2, X2 = D2, X3 = E2, X4 = F2, X5 = G2, X6 = A2, X7 = B2,
    L1 = C3, L2 = D3, L3 = E3, L4 = F3, L5 = G3, L6 = A3, L7 = B3,
    M1 = C4, M2 = D4, M3 = E4, M4 = F4, M5 = G4, M6 = A4, M7 = B4,
    H1 = C5, H2 = D5, H3 = E5, H4 = F5, H5 = G5, H6 = A5, H7 = B5,
    LOW_SPEED = 500, MIDDLE_SPEED = 400, HIGH_SPEED = 300,
    _ = 0XFF

};



void happy_birthday(){

    HMIDIOUT handle;

    midiOutOpen(&handle, 0, 0, 0, CALLBACK_NULL);

    int volume = 0x7f;

    int voice = 0x0;

    int sleep = 300; int tmp = 5;

    int birthday[] =
{L5,L5,0,L6,L5,M1,L7,_,300,L5,L5,0,L6,L5,M2,M1,_,
300,L5,L5,0,M5,M3,M1,L7,L6,300,M4,M4,0,M3,M1,M2,M1,_,
        
    };

    for (auto i : birthday) {

        if (i == 300) { sleep = 300; continue; }

        if (i == 0) { sleep = 600; continue; }

        if (i == 450) { sleep = 450; continue; }

        if (i == 700) { Sleep(150); continue; }

        if (i == _) {

            Sleep(300);

            continue;

        }



        if (i == 1000) { tmp = +5; continue; }

        voice = (volume << 16) + ((i + tmp) << 8) + 0x90;

        midiOutShortMsg(handle, voice);


        Sleep(sleep);

    }

    midiOutClose(handle);

}
int main()
{
    
    cout << setiosflags(ios::fixed) << setprecision(3);
    double a = 0;
    int color = 31;
    while (color < 38) {
        color++;
        if (color != 38)for (int i = 30; i < color; i++)cout << "*";;
        printf("\033[1;%dm 祝老师生日快乐！", color);
        if (color != 38)for (int i = 30; i < color; i++)cout << "*";
        Sleep(500);
        if (color != 38)system("cls");
    }
   happy_birthday();

    srand(time(0));

    // 隐藏光标
    SetCursorVisibility(false);

    int consoleWidth, consoleHeight;
    GetConsoleSize(consoleWidth, consoleHeight);

    vector<Firework> fireworks;
    int fireworkTimer = 0;
    int maxFireworks = 3;

    cout << endl;

    cout << "按任意键开始非常拙劣和鬼畜的烟花表演，还请见谅，按ESC退出..." << endl;

    if (cin.get() == 27) // ESC键
        return 0;

    system("cls"); // 清屏

    while (true) {
        // 检查是否按下ESC键
        if (GetAsyncKeyState(VK_ESCAPE) & 0x8000) {
            break;
        }

        // 生成新烟花
        if (fireworkTimer <= 0 && fireworks.size() < maxFireworks) {
            Firework newFw;
            InitFirework(newFw, consoleWidth);
            fireworks.push_back(newFw);
            fireworkTimer = Random(20, 50);
        }
        else {
            fireworkTimer--;
        }

        // 更新和绘制所有烟花
        for (auto& fw : fireworks) {
            ClearFirework(fw);
            UpdateFirework(fw);
            DrawFirework(fw);
        }

        // 移除已经消失的烟花
        fireworks.erase(
            remove_if(fireworks.begin(), fireworks.end(),
                [](const Firework& fw) {
                    return fw.exploded && all_of(fw.particles.begin(), fw.particles.end(),
                        [](const Particle& p) { return !p.active; });
                }),
            fireworks.end()
        );

        // 控制帧率
        this_thread::sleep_for(chrono::milliseconds(50));

       
       
    }

    // 显示光标
    SetCursorVisibility(true);

    // 清屏
    system("cls");

    cout << "烟花表演结束！" << endl;
    
    
    return 0;
}


