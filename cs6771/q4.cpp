#include <iostream>
#include <string>
using namespace std;
class Y {
public:
string* operator->() { return new string("abc"); }
};
class X {
public:
Y* operator->() { return new Y(); }
};
int main() {
X x;
cout << x->size() << endl;
}
