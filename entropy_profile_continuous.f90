! S. Sullivan, Jul 2018
module entropy_profile_continuous
   use netcdf

   implicit none
   private
   public :: entropy_run

CONTAINS

   ! equivalent of C. Harrigan main.py
   ! read variable varname from the netcdf4 input_file
   subroutine entropy_run(input_file, varname, timepts, nx, ny)
      character(len=:), allocatable :: input_file, varname
      integer :: id_nc, timepts, nx, ny  
      integer :: varid, i, j, start(4) 
                ! start must have as many dimensions as the variable being read
      real*8 :: H
      real*8, dimension(:,:,:), allocatable :: varval
      real*8, dimension(:,:), allocatable :: active_mat, out_mat
      real*8, dimension(:,:), allocatable :: H_vals      

      !timepts = 174; nx = 192; ny = 192 for Sara's output
      !timepts = 150; nx = 206; ny = 206 for Pierre's output 
      ! Transferred these values to being inputs from entropy_driver
      allocate(varval(nx,ny,timepts))
                 ! Dimension ordering is important in the above allocation
                 ! e.g. nx,ny,timepts may also be used   

      ! open the netcdf file for reading
      call check(nf90_open(input_file, NF90_NOWRITE, id_nc),"Opening netcdf file")

      ! get a variable ID from the file
      call check(nf90_inq_varid(id_nc, varname, varid),"Obtaining input varid")

      ! use the file and variable ID in tandem to "inquire" the variable
      write(*,*) "Reading input field..."
      start = [1, 1, 1, 1]
                    ! start must have as many dimensions as the variable being read
      call check(nf90_get_var(id_nc, varid, varval, start=start),"Reading input")

      print*,"Max, Min of Input: ",maxval(varval),minval(varval)
      print*,"Size of input: ",SIZE(varval,1),SIZE(varval,2),SIZE(varval,3)
      allocate(active_mat(nx,ny),H_vals(timepts,MIN(nx,ny)))

      ! iterate through the time points (For Pierre's data, I started from timepoint 200.)      
      do i = 1, timepts
         print*,"Evaluating time point ",i
         active_mat = varval(i,:,:)
                ! Be careful here: time may be the first or last index ==> active_mat = varval(:,:,i)
         ! iterate through the spatial window sizes
         do j = 1, MIN(nx,ny)
            allocate(out_mat(nx-j+1,ny-j+1))
            ! use the moving window filter on the output matrix
            call moving_window_filter(active_mat,nx,ny,j,out_mat)            
            call calc_entropy(out_mat,nx-j+1,ny-j+1,H)
            H_vals(i,j) = H
            deallocate(out_mat)
         enddo
      enddo
      
      ! save the entropy values to an external file
      open(unit = 7, file = "entropy_day0-9_2d_T302-5_try2",action = "write",status = "replace")
      do i = 1,timepts
         do j = 1,nx
            write(7,'(F8.5)',advance="no") H_vals(i,j)
         enddo
         write(7,'(a)') " "
      enddo
      close(7)

   end subroutine entropy_run

   ! Fortran check that no errors occurred
   subroutine check(status, loc)
      integer, intent(in) :: status
      character(len=*), intent(in) :: loc
     
      if (status /= NF90_NOERR) then
          write(*,*) "Error at ",loc
          write(*,*) NF90_STRERROR(status)
      endif

   end subroutine check

   ! equivalent of C. Harrigan moving_window_filter.py
   ! a window of window_size x window_size slides over input_mat and avg_comp
   ! or same_val_prob is calculated on each of these to generate output_mat
   subroutine moving_window_filter(input_mat, nx, ny, window_size, output_mat)
      integer, intent(in) :: nx, ny, window_size
      real*8, dimension(nx,ny), intent(in) :: input_mat
      real*8, dimension(nx-window_size+1,ny-window_size+1), intent(out) :: output_mat
      real*8, dimension(window_size,window_size) :: sub_mat
      integer :: i, j, i_offset, j_offset
      real*8 :: sum_val

      do i = 1, nx - window_size
         do j = 1, ny - window_size
            do i_offset = 1, window_size
               do j_offset = 1, window_size
                  sub_mat(i_offset,j_offset) = input_mat(i + i_offset, j + j_offset)
               enddo
            enddo
            call thresh_val_prob(sub_mat, window_size, window_size, sum_val)
            output_mat(i,j) = sum_val
         enddo
      enddo

   end subroutine moving_window_filter

   ! calculates the probability (output_val) of a value +/- 10% that in the upper left corner 
   ! throughout input_mat 
   subroutine thresh_val_prob(input_mat, nx, ny, output_val)
      integer, intent(in) :: nx, ny
      real*8, dimension(nx,ny), intent(in) :: input_mat
      real*8, intent(out) :: output_val
      integer :: i, j
      real*8  :: num, pr, eps

      pr  = 0.0d0
      num = input_mat(1,1)
      eps = 0.1d0*num
      do i = 1, nx
         do j = 1, ny
            if (i == 1 .and. j == 1) then
                continue
            else
               if (input_mat(i,j) <= num + eps .AND. input_mat(i,j) >= num - eps) pr = pr + 1d0
            endif
         enddo
      enddo

      output_val = REAL(pr / (i * j))    ! pr / (nx * ny)

   end subroutine thresh_val_prob

   ! equivalent of C. Harrigan neighborhood_functions.py
   ! calculates the average element (output_val) in input_mat
   subroutine avg_comp(input_mat,nx,ny,output_val)
      integer, intent(in) :: nx, ny
      real*8, dimension(nx,ny), intent(in) :: input_mat
      real*8, intent(out) :: output_val
      integer :: num, i, j
      real*8  :: tot

      tot  = 0.0d0
      do i = 1, nx
         do j = 1, ny
            tot = tot + input_mat(i,j)  
            num = num + 1
         enddo
      enddo
      
      output_val = tot / num

   end subroutine avg_comp

   ! equivalent of C. Harrigan calculate_profile.py
   ! calculate the information entropy (H) of a matrix of probabilities (prob)
   subroutine calc_entropy(prob, nx, ny, H)
      integer, intent(in) :: nx, ny
      real*8, dimension(nx,ny), intent(in) :: prob
      real*8, intent(out) :: H
      integer :: i, j
      real*8 :: tot

      tot = 0d0
      do i = 1, nx
         do j = 1, ny 
            if (prob(i,j) /= 0d0) then
                tot = tot + prob(i,j) * log(prob(i,j)) / log(2.)
            endif
         enddo
      enddo
    
      if (tot /= 0d0) then
          tot = -1*tot
      endif
      ! normalize by the grid size
      H = tot/(nx * ny)
       
   end subroutine calc_entropy

end module entropy_profile_continuous
