class Base{
public:
	Base() = default;
    Base(int i) noexcept
    	: foo_{i}
    {
    }
	virtual void print(){

	}
protected:
private:
	//data members and implementation members only
	int foo_{5};
};

class Derived : public Base{
public:
	Derived(int i)
		: Base{i}
	{
	}
	void() override{
		std::cout<<"Hello World\n";
	}
};

int main(){
	Base d = Derived{4};
	d.print(); //Prints foo_ because slici(ng problem.
	
		auto d = Derived{4};
		Base& b = d;
		Derived& d2 = dynamic_cast<Derived&>(b);
		d2.print();
}