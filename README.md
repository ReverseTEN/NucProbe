
<h1 align="center">
  <br>
<img src="https://github.com/ReverseTEN/NucProbe/assets/59805766/655e24af-012b-415e-a876-de3d36b5e721" alt="NucProbe"></a>
</h1>
<h4 align="center"> Automate Nuclei scans and streamline bug hunting workflows </h4>

<p align="center">
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-_red.svg"></a>
<a href="https://github.com/ReverseTEN/NucProbe/issues"><img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat"></a>
</p>

<p align="center">




# NucProbe - Automating Nuclei Scans for Bug Hunters

NucProbe is a Bash script designed for bug hunters, offering a streamlined and efficient approach to conducting comprehensive security assessments using the Nuclei scanner. With its automated features, NucProbe empowers bug hunters to stay ahead of the game and maximize their productivity. Let's explore why NucProbe is an invaluable tool for bug hunters:

Read more about NucProbe in my Medium article: [Automating Nuclei Scans for Bug Hunters with NucProbe](https://medium.com/@ReverseTEN/nucprobe-automating-nuclei-scans-for-bug-hunters-29f378897f61)




## Why Use NucProbe?

1. **Saves Time and Effort**: NucProbe automates several crucial tasks, such as updating the Nuclei engine and managing Nuclei templates. Bug hunters can focus on analyzing scan results and identifying vulnerabilities rather than spending time on manual updates.

2. **Keeps Templates Up to Date**: NucProbe ensures that you always have the latest version of Nuclei templates. It automatically fetches and updates templates from the official [projectdiscovery/nuclei-templates](https://github.com/projectdiscovery/nuclei-templates) repository and ***downloading the latest templates from the commits*** ensuring you have access to the most up-to-date detection capabilities.

3. **Effortless Scanning**: Conducting Nuclei scans becomes a breeze with NucProbe. Simply list your target URLs or IP addresses in the `targets.txt` file, and NucProbe will handle the scanning process, saving the output for analysis.

4. **Output Comparison**: NucProbe provides a convenient way to compare the current scan output with the previous one. This feature helps bug hunters quickly identify any new findings or changes, ensuring that no potential vulnerabilities go unnoticed.

5. **Customizable Notifications**: NucProbe allows you to set up custom notifications based on your preferred method. you can easily integrate it using the `send_notification` function, keeping you informed about scan results, updates, and new findings.

## Features

NucProbe offers a range of powerful features tailored to bug hunters' needs:


- **TemplateFetcher**: NucProbe's TemplateFetcher is a powerful feature that simplifies bug hunting by automatically downloading the latest templates from the commits in the official projectdiscovery/nuclei-templates repository. By fetching templates directly from commits, TemplateFetcher ensures bug hunters stay up to date with the most recent and effective templates, enabling them to efficiently identify emerging threats and vulnerabilities through Nuclei scans.

- **Nuclei Engine Management**: Automatically checks for updates to the Nuclei engine and performs the update if necessary. This ensures you are always using the latest version with improved performance and bug fixes.

- **Nuclei Templates Management**: Fetches the latest Nuclei templates from the official repository and keeps them up to date. You can leverage the continually evolving detection capabilities provided by the Nuclei community.

- **Efficient Scanning**: Conducts comprehensive Nuclei scans on specified targets, saving the output in an organized manner for further analysis and action. This allows you to focus on reviewing the results and identifying potential vulnerabilities.

- **Output Comparison**: NucProbe streamlines bug hunting by automatically comparing the latest scan output with the previous one. This powerful feature enables bug hunters to effortlessly identify new items, receive timely notifications for discovered vulnerabilities or changes, and stay ahead of the game. With comprehensive output comparison and real-time notifications, NucProbe ensures thorough analysis, maximizing the effectiveness of bug hunting efforts.



## Workflow :

This workflow provides a more detailed overview of the steps involved in NucProbe's operation, including setting up directories, updating the Nuclei engine, fetching templates, executing scans, and sending notifications.


```mathematica
├── 1. Start
│
├── 2. Clone NucProbe repository
│
├── 3. Download YAML files
│   │
│   ├── For each commit in the repository
│   │   │
│   │   ├── Get commit details
│   │   │
│   │   ├── Extract YAML file URL and filename
│   │   │
│   │   └── Download YAML file
│   │
│   └── Update list of downloaded files
│
├── 4. Check for new files
│   │
│   └── If new files were downloaded
│       │
│       ├── 5. Set up directories
│       │   │
│       │   ├── Create output directory if it doesn't exist
│       │   │
│       │   └── Set paths for template and scan output directories
│       │
│       ├── 6. Update Nuclei engine
│       │   │
│       │   └── Download latest Nuclei engine binary
│       │   │
│       │   └── Start new scan with updated engine
│       │
│       ├── 7. Fetch latest templates
│       │   │
│       │   ├── Get list of available templates
│       │   │
│       │   ├── Download new/updated templates
│       │   │
│       │   └── Merge templates with existing ones
│       │   │
│       │   └── Start new scan with updated templates
│       │
│       ├── 8. Execute Nuclei scans
│       │   │
│       │   ├── Read target URLs/IPs from targets.txt file
│       │   │
│       │   ├── For each target
│       │   │   │
│       │   │   ├── Run Nuclei scan with specified templates
│       │   │   │
│       │   │   └── Save scan output to scan output directory
│       │   │   │
│       │   │   └── Compare output with previous scan
│       │   │
│       │   └── Send notification for new findings
│       │
│       └── 9. Send notification
│           │
│           └── Notify user about new files, engine updates, and scan completion
│
└── 10. End



```





## Get Started with NucProbe

To start utilizing the power of NucProbe, follow these simple steps:

1. **Clone the NucProbe repository**:

   ```bash
   git clone https://github.com/ReverseTEN/nucprobe.git
   cd nucprobe
   chmod +x NucProbe.sh TemplateFetcher.sh

   ```

2. **Requirements:**

Before running the script, ensure that the following packages are installed:

- [nuclei](https://github.com/projectdiscovery/nuclei) : Fast and customizable vulnerability scanner based on simple YAML based DSL.
- [anew](https://github.com/tomnomnom/anew) : a tool that filters out elements from a list that already exist in another list.
- [notify](https://github.com/projectdiscovery/notify) : notify is a lightweight and user-friendly tool that makes it easy to send notifications to messaging platforms like Slack, Discord, and Telegram.


3. **Configure the Directories**:

Set Up GitHub Access Token:

Obtain a GitHub access token to access the Nuclei templates repository. Replace `<YOUR_GITHUB_TOKEN>` in the script with your actual token.

Configure Notification Settings:

Customize the `send_notification` function according to your preferred notification method.

Provide Target URLs/IPs:

List the target URLs or IP addresses you want to scan in the `targets.txt` file. Ensure each target is on a new line.


Run NucProbe:

To automate the NucProbe script and schedule it to run at a custom interval, you can easily set up a cron job.

```bash

*/<custom_interval> * * * * /path/to/NucProbe.sh

```

NucProbe will automatically handle the Nuclei engine updates, template fetching, and scanning process. Sit back and let it do the heavy lifting for you!



## Contributing :

Contributions to NucProbe are highly welcome! If you encounter any issues, have suggestions, or want to contribute improvements to the tool, please feel free to open an issue or submit a pull request. Your contributions will enhance NucProbe's functionality and benefit the bug hunting community.

## License :

NucProbe is released under the MIT License. Feel free to use, modify, and distribute the script as per the license terms.

## Disclaimer:

Please note that the use of NucProbe or any other security assessment tool should comply with the applicable laws and regulations. Usage of this script for any unauthorized or malicious activities is strictly prohibited. 
