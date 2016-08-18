sudo hab studio -k prism build .
sudo hab install ./results/prism-0.0.1-*.hart
sudo hab pkg export docker prism/prism/0.0.1
