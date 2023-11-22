# How to use guide

1. Clone this repo into ~/.fgfs

```
git clone --recurse-submodules 	https://github.com/momentux/fgconfig.git
```

2. Add symbolic link to fgfsrc

```
ln -sfn ~/.fgfs/.fgfsrc ~/.fgfsrc
```

3. Define scenarios in [Aircrafts/f16/Scenarios](Aircrafts/f16/Scenarios)

4. Captur outputs by modifying [jsbsim config](Aircrafts/f16/f16b60.xml)

5. Define routes [example](config/route-kxta-ktnx.xml) and pass them in [.fgfsrc](.fgfsrc)
