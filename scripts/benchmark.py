import torch, time

def smoke_test(duration=10, size=8192, warmup=10):
    a = torch.randn(size, size, device='cuda', dtype=torch.float16)
    b = torch.randn(size, size, device='cuda', dtype=torch.float16)
    torch.cuda.synchronize()

    for _ in range(warmup):
        torch.mm(a, b)
    torch.cuda.synchronize()

    start = time.perf_counter()
    torch.mm(a, b)
    torch.cuda.synchronize()
    iter_time = (time.perf_counter() - start) or 1e-9

    ops = max(int(duration / iter_time), 1)

    start = time.perf_counter()
    for _ in range(ops):
        torch.mm(a, b)
    torch.cuda.synchronize()
    elapsed = time.perf_counter() - start

    tflops = (2 * size**3 * ops) / elapsed / 1e12
    print(f"{tflops:.1f} TFLOPS over {elapsed:.1f}s ({ops} iterations)")
    return tflops

smoke_test()