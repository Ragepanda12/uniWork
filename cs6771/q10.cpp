#include <list>
using namespace std;
int main(){
   list<int> *i = new list<int>();
   list<int> *&j = i;
   list<int> *&&k = std::move(j);
}
