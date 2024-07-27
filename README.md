# pacman_auto_update
Automatic update of Pacman in Archlinux or Manjaro

### Prerequisites

* Pacman
* Bash
* Crontab

### Installing

* Download the script and copy it to the /opt folder or whatever you prefer 
* Make it executable
* Add it to your crontab

### Crontab file

```
@reboot root sleep 300 && cd /opt/ && ./script.sh
0 */1 * * * root cd /opt/ && ./script.sh
```

## Authors

* **Yakciel Lopez Chaviano** - *Pacman auto update* - [gityakjob](https://github.com/gityakjob)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
