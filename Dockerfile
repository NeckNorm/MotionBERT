# Use NVIDIA CUDA Image
FROM nvidia/cuda:11.5.2-devel-ubuntu20.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    vim \
    git \
    build-essential \
    libyaml-dev \
    locales

# Generate en_US.UTF-8 locale
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Install Anaconda
RUN wget https://repo.anaconda.com/archive/Anaconda3-2024.02-1-Linux-x86_64.sh -O /tmp/anaconda.sh && \
    /bin/bash /tmp/anaconda.sh -b -p /root/anaconda3 && \
    rm /tmp/anaconda.sh

# Set PATH for Anaconda
ENV PATH /root/anaconda3/bin:$PATH

# Create a Conda virtual environment for MotionBERT
RUN conda create -n motionbert python=3.7 -y

# Activate the virtual environment and install PyTorch
RUN echo "source activate motionbert" > ~/.bashrc && \
    /bin/bash -c "source activate motionbert && \
    conda install pytorch torchvision torchaudio cudatoolkit=11.3 -c pytorch -c nvidia -y"

# Set environment variables for CUDA
ENV PATH=/usr/local/cuda/bin/:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH

# Install PyTorch3D (Optional)
RUN echo "source activate motionbert" > ~/.bashrc && \
    /bin/bash -c "source activate motionbert && \
    conda install -c fvcore -c iopath -c conda-forge fvcore iopath && \
    conda install -c bottler nvidiacub && \
    pip install 'git+https://github.com/facebookresearch/pytorch3d.git@stable'"

# Install Flask and other Python packages
RUN /bin/bash -c "source activate motionbert && \
    pip install flask flask_socketio pyyaml easydict"

# Set the working directory to the MotionBERT directory
WORKDIR /MotionBERT

# Ensure the conda environment is activated when the container starts and run the API
CMD ["/bin/bash", "-c", "source activate motionbert && python /MotionBERT_api/app.py"]
