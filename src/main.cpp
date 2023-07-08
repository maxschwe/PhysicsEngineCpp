#include <iostream>
#include <SFML/Graphics.hpp>

#include "config.hpp"

using namespace std;
using namespace sf;

int main()
{
    cout << "Starting application" << endl;
    RenderWindow window(sf::VideoMode(WINDOW_WIDTH, WINDOW_HEIGHT), WINDOW_TITLE);
    CircleShape shape(300);
    shape.setPointCount(100000);
    shape.setFillColor(Color::Red);

    while (window.isOpen())
    {
        Event event;
        while (window.pollEvent(event))
        {
            if (event.type == Event::Closed)
                window.close();
        }
        window.clear();

        window.draw(shape);

        window.display();
    }

    return 0;
}