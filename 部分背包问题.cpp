#include<iostream>
#include<algorithm>
#include<vector>
#include<iomanip>
using namespace std;

struct Coin{
    int weight;
    int value;
};



int main(){
    int N,T;
    cin>>N>>T;
    vector<Coin>coin(N);
    for(int i=0;i<N;i++){
        cin>>coin[i].weight>>coin[i].value;
    }
    sort(coin.begin(), coin.end(), [](const Coin& a, const Coin& b){
        double ratio_a = static_cast<double>(a.value) / a.weight;
        double ratio_b = static_cast<double>(b.value) / b.weight;
        return ratio_a>ratio_b;
    });
    double totle=0.0;
    int weight=0;
    for (const auto& co : coin) {
        if(weight+co.weight<=T){
            totle+=co.value;
            weight+=co.weight;
        }
        else{
            int can=T-weight;
            totle+=(static_cast<double>(can) / co.weight) * co.value;
            break;
        }
    }

    cout<<fixed<<setprecision(2)<<totle;
    return 0;
}