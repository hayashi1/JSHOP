module ItemsHelper
  def show_stars(point)
    stars = '';
    point_floor = point.floor
    point_round = point.round
    point_floor.times do
      stars << image_tag('star_full.png')
    end
    stars << image_tag('star_half.png') if point_floor != point_round
    (5 - point_round).times do
      stars << image_tag('star_none.png')
    end
    return stars
  end
end
