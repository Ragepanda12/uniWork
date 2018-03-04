#include<iostream>
using namespace std;
template <typename T> class BigNumber {};
template <typename T> T foo(T) {
cout << "1 ";
}
template <typename T> BigNumber<T> foo(BigNumber<T>) {
cout << "2 ";
}
template<> double foo<double>(double) {
cout << "3 ";
}
int main() {
BigNumber<double> z;
foo(2);
foo(2.0);
foo(z);
}
