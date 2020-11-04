// 〜保留〜
// #define map(a, b, c)({ \
//   std::vector<c> _result;\
//   _result.reserve(a.size());\
//   std::transform(std::begin(a), std::end(a), std::back_inserter(_result), b);\
//   _result;\
// })
#include <iostream>
#include <string>
#include <vector>

namespace ka23 {
  int plus(int a, int b) {
    return a + b;
  }
  float plus(float a, float b) {
    return a + b;
  }

  int minu(int a, int b) {
    return a - b;
  }
  float minu(float a, float b) {
    return a - b;
  }

  int mult(int a, int b) {
    return a * b;
  }
  float mult(float a, float b) {
    return a * b;
  }

  int divi(int a, int b) {
    return a / b;
  }
  float divi(float a, float b) {
    return a / b;
  }

  // lt関数
  bool lt(int a, int b) {
    return a < b;
  }
  bool lt(float a, float b) {
    return a < b;
  }

  // gt関数
  bool gt(int a, int b) {
    return a > b;
  }
  bool gt(float a, float b) {
    return a > b;
  }

  // le関数
  bool le(int a, int b) {
    return a <= b;
  }
  bool le(float a, float b) {
    return a <= b;
  }

  // ge関数
  bool ge(int a, int b) {
    return a >= b;
  }
  bool ge(float a, float b) {
    return a >= b;
  }

  // ee関数
  bool ee(int a, int b) {
    return a == b;
  }
  bool ee(float a, float b) {
    return a == b;
  }
  bool ee(char a, char b) {
    return a == b;
  }
  bool ee(std::string a, std::string b) {
    return a == b;
  }
  bool ee(bool a, bool b) {
    return a == b;
  }

  // ne関数
  bool ne(int a, int b) {
    return a != b;
  }
  bool ne(float a, float b) {
    return a != b;
  }
  bool ne(char a, char b) {
    return a != b;
  }
  bool ne(std::string a, std::string b) {
    return a != b;
  }
  bool ne(bool a, bool b) {
    return a != b;
  }

  // len関数 TODO: 多次元配列に対応させる
  int len(std::vector<int> a) {
    return (int)a.size();
  }
  int len(std::vector<float> a) {
    return (int)a.size();
  }
  int len(std::vector<char> a) {
    return (int)a.size();
  }
  int len(std::vector<std::string> a) {
    return (int)a.size();
  }
  int len(std::vector<bool> a) {
    return (int)a.size();
  }

  // join関数 TODO: 多次元配列に対応させる
  std::vector<int> join(std::vector<int> a, std::vector<int> b) {
    std::vector<int> c;
    c.reserve(a.size() + b.size());
    c.insert(c.end(), a.begin(), a.end());
    c.insert(c.end(), b.begin(), b.end());
    return c;
  }
  std::vector<float> join(std::vector<float> a, std::vector<float> b) {
    std::vector<float> c;
    c.reserve(a.size() + b.size());
    c.insert(c.end(), a.begin(), a.end());
    c.insert(c.end(), b.begin(), b.end());
    return c;
  }
  std::vector<char> join(std::vector<char> a, std::vector<char> b) {
    std::vector<char> c;
    c.reserve(a.size() + b.size());
    c.insert(c.end(), a.begin(), a.end());
    c.insert(c.end(), b.begin(), b.end());
    return c;
  }
  std::vector<std::string> join(std::vector<std::string> a, std::vector<std::string> b) {
    std::vector<std::string> c;
    c.reserve(a.size() + b.size());
    c.insert(c.end(), a.begin(), a.end());
    c.insert(c.end(), b.begin(), b.end());
    return c;
  }
  std::vector<bool> join(std::vector<bool> a, std::vector<bool> b) {
    std::vector<bool> c;
    c.reserve(a.size() + b.size());
    c.insert(c.end(), a.begin(), a.end());
    c.insert(c.end(), b.begin(), b.end());
    return c;
  }

  // auto head = [](auto a) {
  //   return a[0];
  // };

  void print(int a) {
    std::cout << a << "\n";
  }
  void print(float a) {
    std::cout << a << "\n";
  }
  void print(char a) {
    std::cout << a << "\n";
  }
  void print(std::string a) {
    std::cout << a << "\n";
  }
  void print(bool a) {
    if (a == true) {
      std::cout << "true" << "\n";
    } else {
      std::cout << "false" << "\n";
    }
  }
}