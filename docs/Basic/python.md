

## CUDA

#### check cuda version:
```sh
nvcc --version
```

#### check cudnn version:
```sh
python -c "import torch; print(torch.backends.cudnn.version())"
```

#### check cuda torch is installed:
```sh
python -c "import torch; print(torch.version.cuda)"
```

#### check onnxruntime is installed:
```sh
python -c "import onnxruntime; print(onnxruntime.__version__)"
```

or

```sh
pip show onnxruntime-gpu
```
