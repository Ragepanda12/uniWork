#include<list>
#include<iostream>
using namespace std;
class B {
public:
virtual void f() { cout << "B::f() "; }
void g() { cout << "B::g() "; }
};
class D : public B {
public:
virtual void f() { cout << "D::f() "; }
void g() { cout << "D::g() "; }
};
int main() {
B* o1=new D();
o1->f();
o1->g();
B o2=*o1;
o2.f();
}
