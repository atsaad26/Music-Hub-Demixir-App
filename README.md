# Music Hub Demixing Mobile Application

> Music source separation on mobile

> :warning: This project is still in development, all the features might not work perfectly yet.

| Platform | Support            |
| -------- | ------------------ |
| Android  | :white_check_mark: |
| iOS      | Coming soon        |

## Music Source Separation

Music source separation is the task of decomposing music into its constitutive components, e.g., yielding separated stems for the vocals, bass, and drums.

## Features

* Load songs from the device
  * Supported formats: `mp3` and `wav`
* Source separation into 4 different stems: `Vocals`, `Bass`, `Drums`, and `Other`
* Local library of unmixed songs
* Integrated music player with the ability to mute/unmute each stem

## Demixing

The **demixing** is powered by `PyTorch Mobile` and a source separation model optimized for mobile.

### Models

[Open-Unmix](https://github.com/sigsep/open-unmix-pytorch) is a deep neural network reference implementation for music source separation in [Pytorch](https://pytorch.org/).

The models are trained on the [MUSDB18](https://sigsep.github.io/datasets/musdb.html) dataset.

Two models are available in the application:

| Model   | Description                                                  |
| ------- | ------------------------------------------------------------ |
| `umxl`  | A model trained on extra data, significantly improving performance and generalization. |
| `umxhq` | Default model trained on [MUSDB18-HQ](https://sigsep.github.io/datasets/musdb.html#uncompressed-wav), which contains uncompressed tracks yielding a full bandwidth of 22050 Hz. |

To use these models on mobile, they are converted to [TorchScript](https://pytorch.org/docs/stable/jit.html) and optimized for mobile with the `PyTorch Mobile` lite interpreter: https://github.com/demixr/openunmix-torchscript.

Latest mobile build of the models: https://github.com/demixr/openunmix-torchscript/releases/latest/.

## Performance

Using a Pixel 6, demixing a 4-minute audio file takes:
* 3 minutes using the quantized `umxhq` model.
* 4 minutes 10 seconds using the quantized `umxl` model.

The quantized `umxhq` model is around 2.3x faster than the `umxhq` model.
The quantized `umxl` model is at least 3.4x faster than the `umxl` model.

> Note: Inference is done on CPU as GPU is not yet fully supported by PyTorch Mobile.

## Download Music Hub

You can download and install the Android application from the [latest GitHub release](https://github.com/demixr/demixr-app/releases/latest/) by selecting the appropriate platform `apk` file.

## Contributing

You are more than welcome to contribute to **Music Hub**, whether it's for:

* Reporting a bug
* Discussing the current state of the code
* Submitting a fix
* Proposing new features
* Becoming a maintainer

### Report a Bug

You can report bugs using GitHub issues. Consider filling in the following information for an optimal report:

* Quick summary
* Steps to reproduce
* What you expected to happen
* What actually happened
* A screenshot if the bug is graphical

### Submitting a New Feature/Fix

1. Fork the repo and create your branch from `main`.
2. Make sure to add documentation and tests if necessary.
3. Create a pull request.
