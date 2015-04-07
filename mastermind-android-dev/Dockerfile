FROM dockerbase/android

RUN sudo apt-add-repository ppa:george-edison55/cmake-3.x -y && \
	sudo apt-get update && \
	sudo apt-get dist-upgrade -y && \
	sudo apt-get install cmake libreadline-dev libncurses5 libsdl2-2.0 libsdl2-ttf-dev ant unzip -y

RUN curl -O https://www.libsdl.org/release/SDL2-2.0.3.tar.gz && \
	tar xvzf SDL2-2.0.3.tar.gz
RUN curl -O https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.12.tar.gz && \
	tar xvzf SDL2_ttf-2.0.12.tar.gz
RUN curl -O http://gnu.mirrors.pair.com/savannah/savannah//freetype/freetype-2.5.5.tar.bz2 && \
	tar xvjf freetype-2.5.5.tar.bz2
