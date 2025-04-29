# Python

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

#### check cuda(full)
```sh
python -c "import torch, torchvision; pt_v = torch.__version__; cuda_ok = torch.cuda.is_available(); tv_v = torchvision.__version__; print(f'PyTorch version: {pt_v}'); print(f'CUDA available: {cuda_ok}'); cuda_details = (f'CUDA version: {torch.version.cuda}\\nNumber of GPUs: {torch.cuda.device_count()}\\nCurrent device: {torch.cuda.current_device()}\\nDevice name: {torch.cuda.get_device_name(torch.cuda.current_device())}' if cuda_ok else 'CUDA is not available. Check installation and drivers.'); print(cuda_details); print(f'Torchvision version: {tv_v}')"
```

