%{?!ros_distro:%global ros_distro @(Rosdistro)}
%global pkg_name @(Name)
%global normalized_pkg_name %{lua:return (string.gsub(rpm.expand('%{pkg_name}'), '_', '-'))}

Name:           @(Package)
Version:        @(Version)
Release:        @(RPMInc)%{?dist}
Summary:        ROS %{pkg_name} package

License:        @(License)
@[if Homepage and Homepage != '']URL:            @(Homepage)@\n@[end if]@
Source0:        %{name}-%{version}.tar.gz
@[if NoArch]@\nBuildArch:      noarch@\n@[end if]@

BuildRequires:  bloom-rpm-macros
BuildRequires:  python%{python3_pkgversion}-devel

%{?bloom_package}

%description
@(Description)


%package devel
Release:        %{release}%{?release_suffix}
Summary:        %{summary}
Provides:       %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-runtime%{?_isa} = %{version}-%{release}

%description devel
@(Description)


%package runtime
Release:        %{release}
Summary:        %{summary}

%description runtime
@(Description)


%prep
%autosetup -p1


%generate_buildrequires
%bloom_buildrequires


%build
%py3_build


%install
%py3_install -- --prefix "%{bloom_prefix}"


%if 0%{?with_tests}
%check
# Look for a directory with a name indicating that it contains tests
TEST_TARGET=$(ls -d * | grep -m1 "^\(test\|tests\)" ||:)
if [ -n "$TEST_TARGET" ] && %__python3 -m pytest --version; then
# In case we're installing to a non-standard location, look for a setup.sh
# in the install tree and source it.  It will set things like
# CMAKE_PREFIX_PATH, PKG_CONFIG_PATH, and PYTHONPATH.
%__python3 -m pytest $TEST_TARGET || echo "RPM TESTS FAILED"
else echo "RPM TESTS SKIPPED"; fi
%endif


%files devel
%ghost %{bloom_prefix}/share/%{pkg_name}/package.xml


%files runtime
@[for lf in LicenseFiles]%license @lf@\n@[end for]@
%{bloom_prefix}


%changelog@[for change_version, (change_date, main_name, main_email) in changelogs]
* @(change_date) @(main_name) <@(main_email)> - @(change_version)
- Autogenerated by Bloom
@[end for]@
