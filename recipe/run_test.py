# import pkg_resources
import vtk
import sys
import os

# If this fails it raises a DistributionNotFound exception
# pkg_resources.get_distribution('vtk')

if sys.platform != 'darwin' or os.environ.get('build_variant') == 'osmesa':
  # Linux and Windows can't run these tests on headless nodes, and OSX
  # is where the problem was happening anyway
  # The test hangs with build_variant == "osmesa", so disabling for now.
  sys.exit(0)
  
# test libpng, since this was causing trouble in OSX previously
source = vtk.vtkCubeSource()

mapper = vtk.vtkPolyDataMapper()
mapper.SetInputConnection(source.GetOutputPort())

actor = vtk.vtkActor()
actor.SetMapper(mapper)

renderer = vtk.vtkRenderer()
renderer.AddActor(actor)

window = vtk.vtkRenderWindow()
window.AddRenderer(renderer)
window.SetSize(500, 500)
window.Render()

window_filter = vtk.vtkWindowToImageFilter()
window_filter.SetInput(window)
window_filter.Update()

writer = vtk.vtkPNGWriter()
writer.SetFileName('cube.png')
writer.SetInputData(window_filter.GetOutput())
writer.Write()
