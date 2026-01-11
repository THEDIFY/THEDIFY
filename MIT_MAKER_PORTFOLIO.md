# MIT Maker Portfolio Responses

---

## 3. Portfolio Summary (600 characters max)

I build AI systems that democratize access to resources traditionally reserved for the privileged. My portfolio spans four production-grade projects: **EDIFY**, an enterprise AI education platform with a novel RAG technique achieving sub-2-second responses for 100+ concurrent users; **MenTora**, a PWA delivering interactive AI/ML courses with in-browser Python environments; **GUIRA**, a multi-modal wildfire prediction system using 5 specialized deep learning models (YOLOv8, TimeSFormer, ResNet50, CSRNet) providing 30-60 minute advance warnings; and **Axolotl**, a computer vision sports analytics platform processing 45 FPS video with pose estimation and AI coaching. Each project addresses inequality—in education, disaster preparedness, or athletics—through accessible, production-ready AI solutions.

---

## 4. Project Highlight (900 characters max)

GUIRA's hybrid physics-neural fire spread model fascinates me most. The challenge: predicting how wildfires propagate requires both understanding fire physics AND processing real-time environmental data. I combined a physics-based Rothermel fire model (calculating spread rate from fuel moisture, wind, slope) with neural networks that learn from satellite imagery patterns—creating a system where physics constrains the AI's predictions within physical plausibility while ML captures patterns physics alone can't model.

The breakthrough came when implementing the VARI (Visible Atmospherically Resistant Index) vegetation health layer. I discovered that feeding spectral indices directly into ResNet50's first convolutional layer—rather than treating them as separate input streams—significantly improved the model's ability to identify fire-prone dry vegetation. This 4-channel input (RGB + VARI) lets the network learn joint representations between visual appearance and vegetation stress, achieving 95%+ detection accuracy. Watching the system correctly predict fire paths during testing—seeing mathematics and machine learning work together to potentially save lives—was deeply meaningful.

---

## 5. Maker Context (600 characters max)

I work from a modest home setup in Mexico: a single laptop with an NVIDIA GPU, no formal makerspace. Cloud resources (Azure credits from student programs) enable training larger models. I acquired skills autodidactically—studying PyTorch documentation, research papers (YOLO, TimeSFormer architectures), and open-source codebases. My constraints are significant: no institutional support, limited hardware, and working in Spanish-speaking communities with few AI resources. These constraints shaped my mission: if I can build production AI systems with minimal resources, I can design systems accessible to others facing similar barriers. Online communities (Hugging Face forums, GitHub discussions) and Microsoft Learn documentation have been invaluable mentors.

---

## 6. Collaborators (600 characters max)

I am the **sole developer** on all four projects—EDIFY, MenTora, GUIRA, and Axolotl. I designed the system architectures, implemented all code (frontend React/TypeScript, backend FastAPI/Python, AI/ML pipelines), wrote documentation, and deployed to Azure cloud infrastructure. No direct collaborators or mentors contributed code or designs.

My role in each project:
- **EDIFY/MenTora**: Full-stack development, RAG algorithm design, Azure integration
- **GUIRA**: All 5 AI model implementations, physics-neural hybrid design, geospatial systems
- **Axolotl**: Computer vision pipeline, pose estimation integration, real-time processing architecture

No collaborators are submitting MIT Maker Portfolios this year.

---

## 7. Sources & Citations (900 characters max)

**AI/ML Frameworks & Pre-trained Models:**
- YOLOv8: Ultralytics (https://github.com/ultralytics/ultralytics) - used pretrained weights, custom fine-tuning
- MediaPipe Pose: Google's pretrained pose estimation
- TimeSFormer: Facebook Research architecture (adapted from paper)
- SMPL Body Model: Max Planck Institute (license for research)
- ByteTrack: Zhang et al. tracking algorithm implementation

**Datasets (Training/Evaluation):**
- SoccerNet v2 (event spotting), COCO (detection), FLAME/FLAME2 datasets (fire detection, with licenses documented)

**Tutorials & Documentation:**
- Microsoft Learn (Azure AI Search, Cosmos DB, OpenAI integration)
- FastAPI official documentation
- React 19 documentation, TailwindCSS guides

**AI Assistive Tools:**
- GitHub Copilot: Used for code autocompletion and boilerplate generation. I reviewed, modified, and tested all suggestions. Core algorithms, architectures, and novel techniques (hybrid RAG, physics-neural fusion) are my original designs.
- Claude/ChatGPT: Occasionally consulted for debugging specific errors and documentation clarification.

---

## 8. What Motivates You (300 characters max)

I grew up watching brilliant people around me lack opportunities simply because they couldn't afford them. Building AI that levels playing fields—giving a rural student world-class tutoring, or a small community wildfire warnings—transforms my frustration into purpose. Technology should be the great equalizer.

---

## 9. Most Personally Meaningful Project (300 characters max)

EDIFY—because I built what I wished existed when I was struggling to learn. As an autodidact in Mexico with no AI mentors, I spent countless hours lost in fragmented resources. Creating a system that adapts to each learner's goals and provides clear, cited answers feels like building a bridge I once needed.

---

## 10. Question for an Expert (300 characters max)

How do you balance model interpretability with performance in safety-critical systems? In GUIRA's wildfire prediction, I want communities to understand WHY the system predicts danger—building trust—but attention visualizations and SHAP values add latency. What trade-offs do you recommend?

---

## 11. Personal Website / GitHub

**GitHub:** https://github.com/THEDIFY/THEDIFY

The repository contains all four projects with complete documentation:
- `/projects/EDIFY` - Enterprise AI education platform
- `/projects/MenTora` - PWA learning platform
- `/projects/GUIRA` - Wildfire prediction system
- `/projects/Axolotl` - Sports analytics platform

Each project includes: README, ARCHITECTURE.md, API documentation, video demonstrations, and reproducibility guides.

---

## 12. Third-Party Context (Optional)

Not applicable—these projects were created independently for my personal portfolio and mission, not for any competition or grant. All work represents self-directed research and development aimed at democratizing access to AI-powered tools for underserved communities.

---

## 13. Search Keywords / Tags

retrieval-augmented generation education platform, real-time wildfire detection system, hybrid physics-neural fire spread modeling, computer vision sports analytics, pose estimation biomechanical analysis, multi-object video tracking pipeline, in-browser Python learning environment, YOLOv8 smoke detection, video transformer temporal analysis, geospatial vegetation health indexing, semantic vector search fusion, adaptive tutoring system

---

## 🎬 Video Script: Technical Portfolio Walkthrough (~2 minutes)

---

**[0:00 - 0:15] INTRO**

Hi, I'm Santiago—a high school student from Mexico building AI systems that democratize access to technology. Today I'll walk you through the technical architecture of four production-grade projects I've built from scratch.

**[0:15 - 0:45] EDIFY - The RAG Innovation**

EDIFY is an enterprise AI education platform serving 100+ concurrent users. The core innovation is a hybrid Retrieval-Augmented Generation technique. Here's how it works: when a student asks a question, my system performs parallel queries—semantic vector search using Azure AI Search embeddings captures conceptual similarity, while BM25 keyword matching catches exact terminology. I then fuse these results using reciprocal rank fusion before passing context to GPT-4.

The architecture uses FastAPI with async endpoints, Redis for session caching, and Cosmos DB for user data. Response latency stays under 2 seconds at the 95th percentile.

**[0:45 - 1:15] GUIRA - Multi-Modal Wildfire Prediction**

GUIRA combines five deep learning models for wildfire prevention. YOLOv8 handles real-time fire and smoke detection at 30 FPS. TimeSFormer—a video transformer—analyzes 8-frame sequences to predict smoke movement direction.

The breakthrough is my hybrid physics-neural fire spread model. I feed RGB images plus a computed VARI vegetation index as a 4-channel input to ResNet50. This lets the network learn joint representations between visual appearance and vegetation stress levels. A physics-based Rothermel model then constrains the neural predictions within physical plausibility—ensuring spread rates match real-world fuel and wind dynamics.

**[1:15 - 1:40] AXOLOTL - Computer Vision Sports Analytics**

Axolotl processes football match footage at 45 FPS. The pipeline chains YOLOv8 detection into ByteTrack for multi-object tracking using Kalman filtering and Hungarian algorithm matching. MediaPipe extracts 33 body keypoints per player, which I transform into SMPL 3D body meshes for biomechanical analysis.

A custom LSTM trained on SoccerNet detects events—passes, shots, tackles. GPT-4 with RAG then generates personalized coaching feedback based on the player's historical metrics.

**[1:40 - 2:00] MENTORA & CLOSING**

MenTora wraps this technology in an accessible PWA—React 19 frontend with Pyodide running Python directly in the browser for interactive AI exercises.

Every project shares one philosophy: professional-grade AI shouldn't require professional-grade budgets. I built these systems on a single laptop with cloud credits, proving that with the right architecture, we can bring advanced technology to everyone.

Thank you for watching.

---

**[END OF SCRIPT]**

*Total runtime: ~2 minutes at moderate speaking pace*
*Word count: ~380 words*

---
