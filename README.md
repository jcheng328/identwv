<h1 align="center">
Ident-WV
</h1>

<h3 align="center">
WeakIdent with Voting
</h3>

<p align="center">
| <a href=""><b>Documentation</b></a> | <a href=""><b>Paper</b></a> | <a href=""><b>Developer Group</b></a> |
</p>

---
## About

Ident-WV (WeakIdent with Voting) is a powerful framework for identifying differential equations. It leverages a novel dynamics-guided weighted weak form combined with a robust voting mechanism to enhance accuracy and stability in system identification. This approach improves the ability to uncover underlying differential equations from observed data.

## Getting Started
To get started with Ident-WV, follow these simple steps:

Clone the repository:

Bash

```bash
git clone https://github.com/jcheng328/identwv.git
cd identwv
```

Configure your settings: Our configurations are thoughtfully organized into three distinct parts, allowing for precise control over your experiments:
1. [Data Configurations](): Specify how your input data is handled.
2. [Plot Configurations](): Set up preferences for how your figures are plotted.

Once configured, you can run `main.m` to automatically execute the algorithm. This script will persist the results, including common metrics, into a table and log the output to a standard output file located at `.\Results\ModelHandler\identwv\{your_dataset_name}\Output_identwv_{your_dataset_name}.txt`. To visualize your results, run `data_visual.m`. This script retrieves the metrics and generates plots based on your figure preference configuration. The output log can be found at `.\Results\ModelComparer\{your_dataset_name}\Output_ModelComparer.txt`, and the generated plots will be saved in the same directory.

## Contributing

We welcome and value any contributions and collaborations.
Please reach out to us to get involved.

## Citation

If Ident-WV proves valuable in your research, please consider citing our [paper]():

```bibtex
@inproceedings{jcheng2025voting,
  title={Identification of Differential Equations by Dynamics-Guided Weighted Weak Form with Voting},
  author={Jiahui Cheng and Sung Ha Kang and Haomin Zhou and Wenjing Liao},
  booktitle={arxiv},
  year={2025}
}
```

## Contact Us

- For technical questions and feature requests, please use GitHub [Issues](https://github.com/jcheng328/identwv/issues) or [Discussions](https://github.com/jcheng328/identwv/discussions)
- For collaborations and partnerships, please contact us at [jcheng49f@gmail.com](mailto:jcheng49f@gmail.com)
