#include<iostream>
#include<vector>
using namespace std;
void f() {
vector<int> v1(10);
vector<int> *v2 = new vector<int>(10);
throw 100;
cout << "never executed!";
}
int main() {
try { f(); }
catch (int) { }
}
