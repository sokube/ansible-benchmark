cp ansible.cfg.benchmark ansible.cfg
wget https://networkgenomics.com/try/mitogen-0.2.9.tar.gz
tar xzf mitogen-0.2.9.tar.gz
rm -f mitogen-0.2.9.tar.gz
ansible-galaxy install -r requirements.yml
ansible-playbook benchmark.yml --skip-tags with-command
