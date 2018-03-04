#include<iostream>
using namespace std;
class Base {
public:
virtual void f(float) { cout << "Base::f(float)\n"; }
};
class Derived : public Base {
public:
virtual void f(int) { cout << "Derived::f(int)\n"; }
};
int main() {
Derived *d = new Derived();
Base *b = d;
b->f(3.14F);
d->f(3.14F);
}
