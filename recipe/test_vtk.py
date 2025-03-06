import pkg_resources
import vtk
import sys
import os

# If this fails it raises a DistributionNotFound exception
pkg_resources.get_distribution('vtk')

# As of VTK 9.4, Linux and Windows should automatically fall back to using OSMesa
# if there is no valid display or OpenGL is too old, so tests should work on all OSes.

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

# test for https://gitlab.kitware.com/vtk/vtk/-/issues/19258
# test from https://gitlab.archlinux.org/archlinux/packaging/packages/paraview/-/issues/4#note_166231
reader = vtk.vtkXMLUnstructuredGridReader()
reader.SetFileName(os.environ["RECIPE_DIR"] + "/tests/ref.vtu")
reader.Update()
points = reader.GetOutput().GetPoints()
# this will be None with expat 2.6
assert points is not None
assert points.GetNumberOfPoints() == 500
