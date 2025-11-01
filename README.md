# 🎙️ Voice Codec Implementation Using MATLAB  
### CIE 337: Communication Theory and Systems  

**Presented to:** Dr. Samy Soliman  
**Authors:** Aml Tarek · Mohammad Mahmoud · Youssef Allam  

---

## 📖 Project Overview
This project implements a **Voice Codec System** using **MATLAB**, demonstrating the full **Pulse Code Modulation (PCM)** chain — from **sampling** and **quantization** to **encoding**, **transmission**, and **decoding**.  
The implementation explores the effects of **sampling rate**, **quantization levels**, and **channel noise** on reconstructed voice quality.

---

## 🎯 Objectives
- Implement a **voice codec** with:
  1. Sampler  
  2. Quantizer  
  3. Encoder  
  4. Decoder  
- Analyze how **sampling frequency** and **quantization levels (L)** affect signal quality.  
- Implement **Unipolar NRZ** and **Polar NRZ** line coding schemes.  
- Introduce **Additive Gaussian White Noise (AGWN)** and study its effects.  
- Regenerate noisy signals and evaluate decoder accuracy.  

---

## ⚙️ System Components

### 🧩 Sampler
- Performs **natural sampling** on an analog (audio) signal using a specified sampling frequency \( F_s \).  
- Demonstrates how increasing \( F_s \) (5kHz → 20kHz → 40kHz) improves the approximation of the original signal.

### 🔢 Quantizer
- Accepts parameters:
  - **L:** Number of quantization levels  
  - **mp:** Maximum amplitude  
  - **Setting:** Midrise or Midtread quantizer  
- Outputs:
  - Quantized signal  
  - Bitstream representation  
  - Average quantization error  

As **L increases**, quantization error decreases, and the quantized signal approaches the sampled signal.

### 🔠 Encoder
Implements two **line coding** schemes:
| Scheme | Bit ‘1’ | Bit ‘0’ |
|:--------|:--------|:--------|
| **Unipolar NRZ** | +1 | 0 |
| **Polar NRZ** | +1 | -1 |

- Converts quantized bits into corresponding pulse amplitudes.
- Generates pulse trains that represent PCM signals.

### 🔄 Decoder
- Extracts bits from PCM signals by averaging over bit intervals.  
- Translates signal back into binary stream and reconstructs quantized samples.  
- Converts binary to decimal values and reconstructs the original signal.  

---

## 🧪 Experiments and Results

### **Test 1: Effect of Sampling Rate and Quantization Levels**
Parameters:
- Sampling frequencies: **5 kHz**, **20 kHz**, **40 kHz**  
- Quantization levels: **L = 4, 8, 64**

**Findings:**
- Higher \( F_s \) → reconstructed signal more closely resembles original.
- Higher \( L \) → smaller quantization error and smoother reconstruction.
- Listening tests confirm less distortion and higher fidelity for higher \( F_s \) and \( L \).

---

### **Test 2: Effect of Additive Noise and Regeneration**
- Added **Additive Gaussian White Noise (AGWN)** with different **variances (1, 4, 16)**.  
- Tested both **Unipolar** and **Polar NRZ** encodings.  

**Observations:**
- Increased noise variance → more distortion in pulses.  
- Regenerative repeaters successfully restore most pulses.  
- Some bits remain misinterpreted when noise variance is high.  
- Error probability increases with noise power.

---

## 📊 Summary of Key Insights
| Parameter | Effect on Signal Quality |
|:-----------|:-------------------------|
| Higher Sampling Frequency | Improves reconstruction accuracy |
| Higher Quantization Levels | Reduces quantization error |
| Unipolar NRZ | Simpler, but less power-efficient |
| Polar NRZ | Better for DC balance |
| Increased Noise Variance | Increases bit errors |
| Regenerative Repeater | Reduces distortion but not perfect |


---

## 🧾 Conclusion
The project successfully demonstrates a **MATLAB-based voice codec**, showing the entire **PCM process** from sampling to decoding.  
Through controlled tests, it verifies:
- The theoretical relationship between **sampling**, **quantization**, and **signal fidelity**.  
- The effect of **line coding** and **noise** on digital communication.  
- The importance of **error correction and regeneration** in real systems.

