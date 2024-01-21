<div id="top"></div>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
  
<!-- [![LinkedIn][linkedin-shield]][linkedin-url] -->

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/NyanPham/atari-volley">
    <img src="logo.png" alt="Logo" width="200" height="80">
  </a>

<h3 align="center">Nyan's Volley ball</h3>
  <p align="center">
    Simple Volley ball game in 6502 assembly on Atari 2600.
    This is my own implementation of making a game in atari without tutorials. The project is simple and not practical in modern world, yet fun and nostalgic for me. I'm not a geek, but programming in assembly language gives me a sense of freedom despite its limitation. 
    <br />
    <a href="https://github.com/NyanPham/atari-volley"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/NyanPham/atari-volley/issues">Report Bug</a>
    ·
    <a href="https://github.com/NyanPham/atari-volley">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project
![atari-volley](https://github.com/NyanPham/atari-volley/assets/93678376/c21e7429-dc50-4535-b2dd-e1704ebec0e8)

<p align="right">(<a href="#top">back to top</a>)</p>

### Built With

-   [6502 Assembly](http://www.6502.org/)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

Follow the instruction below to run the code locally.

### Prerequisites
To compile the game to executable file, you would need to download the Assembler ([https://dasm-assembler.github.io/ ](https://dasm-assembler.github.io/)), VCS and MACRO headers.
You can find all 3 files from the repository:
    - dasm 
    - vcs.h 
    - macro.h

To run the game, you need to use an Atari Emulator. Stella([https://stella-emu.github.io/downloads.html](https://stella-emu.github.io/downloads.html)) is recommended.

### Installation
Note: This installation is for you running the game on Stella only. You can run the game on Web Emulator as well.
1. Clone the repo
    ```sh
    git clone https://github.com/NyanPham/atari-volley.git
    ```
2. Compile the asm
    ```sh
    ./dasm volley.asm -f3 -v0 -o"cart.bin"
    ``` 

### How to run the game
We have 2 ways:
1. Local emulator: Open the Stella emulator and run the cart.bin file that we have generated from the installation above.
2. Web emulator :
  - Go to this site: [https://www.henryschmale.org/apps/atari2600ide/](https://www.henryschmale.org/apps/atari2600ide/)
  - Copy source code in file "volley.asm", paste in the text field of the site, then click "Run code". 

### Player controls:
1. Local emulator:
  Player 1: Press left/right arrows to move, space to jump
  Player 2: Press G/J keys to move, F to jump
1. Web emulator:  
  Player 1: Press left/right arrows to move, space to jump
  Player 2: Press F/H keys to move, . to jump

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Pham Thanh Nhan - phamthanhnhanussh@gmail.com || nyanphamdev@gmail.com

Project Link: [https://github.com/NyanPham/atari-volley](https://github.com/NyanPham/atari-volley)

LinkedIn: [https://www.linkedin.com/in/nhan-pham-84a602232/](https://www.linkedin.com/in/nhan-pham-84a602232/)

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments
    
<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/NyanPham/todo-app-react.svg?style=for-the-badge
[contributors-url]: https://github.com/NyanPham/atari-volley/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/NyanPham/todo-app-react.svg?style=for-the-badge
[forks-url]: https://github.com/NyanPham/atari-volley/network/members
[stars-shield]: https://img.shields.io/github/stars/NyanPham/todo-app-react.svg?style=for-the-badge
[stars-url]: https://github.com/NyanPham/atari-volley/stargazers
[issues-shield]: https://img.shields.io/github/issues/NyanPham/todo-app-react.svg?style=for-the-badge
[issues-url]: https://github.com/NyanPham/atari-volley/issues
[license-shield]: https://img.shields.io/github/license/NyanPham/todo-app-react.svg?style=for-the-badge
[linkedin-url]: https://www.linkedin.com/in/nhan-pham-84a602232/
