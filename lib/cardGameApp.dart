import 'package:flutter/material.dart';

void main() {
  runApp(CardGameApp());
}

class GameCard {
  bool isFlipped;
  bool isMatched;
  String color;

  GameCard({
    required this.isFlipped,
    required this.isMatched,
    required this.color,
  });
}

class CardGameApp extends StatefulWidget {
  @override
  State<CardGameApp> createState() => CardGameState();
}


class CardGameState extends State<CardGameApp> {
  int _mistakes = 0;
  final int _maxMistakes = 1; 

 
  int _alertStatus = 0;
  String _alertMessage = "";

  List<GameCard> myCards = [
    GameCard(isFlipped: false, isMatched: false, color: "blue"),
    GameCard(isFlipped: false, isMatched: false, color: "red"),
    GameCard(isFlipped: false, isMatched: false, color: "blue"),
    GameCard(isFlipped: false, isMatched: false, color: "red"),
  ];
  
  List<int> selectedIndexes = [];

  void _onCardTap(int index) {
    
    if (_mistakes > _maxMistakes ||
        myCards[index].isMatched ||
        myCards[index].isFlipped ||
        selectedIndexes.length >= 2) {
      return;
    }

    setState(() {
      myCards[index].isFlipped = true;
      selectedIndexes.add(index);
      _alertStatus = 0; 

      if (selectedIndexes.length == 2) {
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    int firstIndex = selectedIndexes[0];
    int secondIndex = selectedIndexes[1];

    if (myCards[firstIndex].color == myCards[secondIndex].color) {
      
      setState(() {
        myCards[firstIndex].isMatched = true;
        myCards[secondIndex].isMatched = true;
        
        bool isAllMatched = myCards.every((card) => card.isMatched);
        _alertStatus = 1;
        _alertMessage = isAllMatched 
            ? "✅ Победа! Все пары найдены." 
            : "✅ Успешно! Ищи следующую пару.";
      });
      selectedIndexes.clear();
    } else {
     
      setState(() {
        _mistakes++;
        _alertStatus = 2;
        
        if (_mistakes > _maxMistakes) {
           _alertMessage = "❌ У вас не осталось попыток.";
        } else {
           int left = _maxMistakes - _mistakes + 1;
           _alertMessage = "❌ Не совпадает! Осталась $left попытка.";
        }
      });

      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            myCards[firstIndex].isFlipped = false;
            myCards[secondIndex].isFlipped = false;
            selectedIndexes.clear();
          });
        }
      });
    }
  }

  
  Color _getCardColor(String colorString) {
    if (colorString == "blue") return const Color(0xFF1656B9);
    if (colorString == "red") return const Color(0xFFCE363B);
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                
                const Text(
                  "Найти пару 🎯",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
               
                const Text(
                  "Нажми на два прямоугольника одного цвета",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

               
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      children: [
                        const TextSpan(text: "Ошибок: ", style: TextStyle(color: Colors.black54)),
                        TextSpan(
                          text: "$_mistakes", 
                          style: TextStyle(color: _mistakes > 0 ? Colors.red : Colors.black87)
                        ),
                        TextSpan(text: " / $_maxMistakes", style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                
                GridView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(), 
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4, 
                  ),
                  itemCount: myCards.length,
                  itemBuilder: (context, index) {
                    final card = myCards[index];
                    final isOpen = card.isFlipped || card.isMatched;

                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300), 
                        decoration: BoxDecoration(
                          color: isOpen ? _getCardColor(card.color) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isOpen 
                              ? null 
                              : Border.all(color: Colors.grey.shade300, width: 1.5),
                        ),
                        child: isOpen
                            ? Center(
                               
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : null, 
                      ),
                    );
                  },
                ),

                
                if (_alertStatus != 0) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _alertStatus == 1 
                          ? Colors.green.shade50 
                          : const Color.fromARGB(255, 255, 235, 235),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _alertMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _alertStatus == 1 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
