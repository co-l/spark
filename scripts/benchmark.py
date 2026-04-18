import torch, time

def smoke_test(duration=5, size=8192):
    a = torch.randn(size, size, device='cuda', dtype=torch.float16)
    b = torch.randn(size, size, device='cuda', dtype=torch.float16)
    torch.cuda.synchronize()
    
    ops = 0
    start = time.perf_counter()
    while time.perf_counter() - start < duration:
        torch.mm(a, b)
        ops += 1
    torch.cuda.synchronize()
    
    elapsed = time.perf_counter() - start
    tflops = (2 * size**3 * ops) / elapsed / 1e12
    print(f"{tflops:.1f} TFLOPS over {elapsed:.1f}s ({ops} iterations)")
    return tflops

smoke_test()