program entropy_driver
    use netcdf
    use entropy_profile_binary
    implicit none
    character(len=:), allocatable :: fichier, var
    integer :: tt, resx, resy
    
    ! output file name
    fichier = "ocean_D576_T305.nc"
    !fichier = "mcs_grids_monthly.nc"

    ! variable name with which to quantify organization in that file
    var = "CLDC"
    !var = "frequency"
    
    ! number of time points over which to quantify organization
    tt = 174
    !tt = 301

    ! spatial resolution in x, y
    resx = 192
    resy = 192
    !resx = 60
    !resy = 180
          !tt = 174; resx = 192; resy = 192 for Sara's output
          !tt = 150; resx = 206; resy = 206 for Pierre's output

    call entropy_run(fichier,var,tt,resx,resy)

end program entropy_driver
